#!/usr/bin/env python

from fastapi import FastAPI, HTTPException, Query, Path
from fastapi.openapi.utils import get_openapi
from pydantic import BaseModel, Field
from datetime import date, datetime, timedelta
import yfinance as yf
import pandas as pd
from typing import List, Optional, Dict, Any

# Define Pydantic Models for API documentation and response validation
class AssetQuote(BaseModel):
    symbol: str
    price: Optional[float] = None
    currency: Optional[str] = None
    exchange_name: Optional[str] = None
    short_name: Optional[str] = None
    timestamp: Optional[datetime] = None
    error: Optional[str] = None

class HistoricalDataPoint(BaseModel):
    date: date
    open: float
    high: float
    low: float
    close: float
    adj_close: float
    volume: int

class HistoricalAssetQuotes(BaseModel):
    symbol: str
    data: List[HistoricalDataPoint]
    error: Optional[str] = None

# Initialize FastAPI app
app = FastAPI(
    openapi_version="3.0.2",
    root_path_in_servers=False,
    servers=[
        {"url": "https://localhost:8000", "description": "Staging environment"}
    ],
)

# --- Helper Function to Fetch Ticker Info ---
def get_ticker_info(symbol: str):
    try:
        ticker = yf.Ticker(symbol)
        # The .info attribute can sometimes be slow or raise an error if the ticker is invalid
        # or data is unavailable.
        info = ticker.info
        if not info or 'symbol' not in info: # Check if info is empty or missing essential data
             # Attempt to get basic history to confirm ticker validity if .info is sparse
            hist = ticker.history(period="1d")
            if hist.empty:
                return None, f"No data found for symbol: {symbol}. It might be an invalid ticker."
            # If history exists but info is still minimal, provide what we can
            return ticker, None # Return ticker object, error is None
        return ticker, None
    except Exception as e:
        # More specific error handling can be added here if needed
        return None, f"Error fetching ticker info for {symbol}: {str(e)}"

# --- API Endpoints ---
@app.get("/quotes/current/{symbol}", response_model=AssetQuote, tags=["Quotes"])
async def get_current_quote(symbol: str = Path(..., title="Asset Ticker Symbol", description="The stock ticker symbol (e.g., AAPL, MSFT, GOOGL)")):
    """
    Retrieves the current (or most recent) market quote for a given asset symbol.
    """
    ticker, error_msg = get_ticker_info(symbol)
    if error_msg:
        return AssetQuote(symbol=symbol, error=error_msg)
    if not ticker: # Should be caught by error_msg, but as a safeguard
        return AssetQuote(symbol=symbol, error=f"Invalid ticker symbol: {symbol}")

    try:
        # For current price, 'fast_info' can be quicker if available and sufficient
        # However, .info is more comprehensive. Let's try to get the most recent closing price
        # from a short history period if direct 'currentPrice' is not reliable.
        todays_data = ticker.history(period="2d") # Fetch last two days to ensure we get the most recent close
        if todays_data.empty:
            return AssetQuote(symbol=symbol, error=f"No recent trading data found for {symbol}.")

        latest_data = todays_data.iloc[-1]
        price = latest_data["Close"]
        timestamp = pd.to_datetime(latest_data.name).to_pydatetime() # Ensure it's a Python datetime

        # Attempt to get more info, but handle potential missing keys gracefully
        info = ticker.info
        currency = info.get('currency')
        exchange_name = info.get('exchangeName', info.get('exchange'))
        short_name = info.get('shortName')

        return AssetQuote(
            symbol=symbol,
            price=price,
            currency=currency,
            exchange_name=exchange_name,
            short_name=short_name,
            timestamp=timestamp
        )
    except KeyError as e:
         return AssetQuote(symbol=symbol, error=f"Data field {e} not found for {symbol}. The ticker might be delisted or data is incomplete.")
    except IndexError:
        return AssetQuote(symbol=symbol, error=f"No historical data found to determine current price for {symbol}.")
    except Exception as e:
        return AssetQuote(symbol=symbol, error=f"An unexpected error occurred while fetching current quote for {symbol}: {str(e)}")


@app.get("/quotes/historical/{symbol}", response_model=HistoricalAssetQuotes, tags=["Quotes"])
async def get_historical_quotes(
    symbol: str = Path(..., title="Asset Ticker Symbol", description="The stock ticker symbol (e.g., AAPL, MSFT, GOOGL)"),
    start_date: date = Query(..., description="Start date for historical data (YYYY-MM-DD)"),
    end_date: date = Query(..., description="End date for historical data (YYYY-MM-DD)")
):
    """
    Retrieves historical market quotes (OHLCV) for a given asset symbol within a specified date range.
    """
    if start_date >= end_date:
        raise HTTPException(status_code=400, detail="Start date must be before end date.")

    ticker, error_msg = get_ticker_info(symbol)
    if error_msg:
        return HistoricalAssetQuotes(symbol=symbol, data=[], error=error_msg)
    if not ticker:
         return HistoricalAssetQuotes(symbol=symbol, data=[], error=f"Invalid ticker symbol: {symbol}")

    try:
        # yfinance expects end_date to be exclusive for daily data if time is not specified,
        # or inclusive if it's the current day. To be safe and inclusive for user's intent:
        history_df = ticker.history(start=start_date, end=end_date + timedelta(days=1), auto_adjust=True) # Add one day to make end_date inclusive

        if history_df.empty:
            return HistoricalAssetQuotes(symbol=symbol, data=[], error=f"No historical data found for {symbol} in the given date range.")

        # Ensure required columns are present
        required_cols = {'Open', 'High', 'Low', 'Close', 'Volume'}
        if not required_cols.issubset(history_df.columns):
            missing_cols = required_cols - set(history_df.columns)
            return HistoricalAssetQuotes(symbol=symbol, data=[], error=f"Missing required data columns from Yahoo Finance: {missing_cols}")


        data_points = []
        for index, row in history_df.iterrows():
            data_points.append(
                HistoricalDataPoint(
                    date=index.date(), # yfinance index is usually a Timestamp
                    open=row["Open"],
                    high=row["High"],
                    low=row["Low"],
                    close=row["Close"],
                    adj_close=row.get("Adj Close", row["Close"]), # Use 'Close' if 'Adj Close' is not available
                    volume=int(row["Volume"])
                )
            )
        return HistoricalAssetQuotes(symbol=symbol, data=data_points)
    except Exception as e:
        return HistoricalAssetQuotes(symbol=symbol, data=[], error=f"An unexpected error occurred while fetching historical quotes for {symbol}: {str(e)}")

# --- OpenAPI Customization ---
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        openapi_version="3.0.2",
        title="Market Quotes API",
        version="1.0.0",
        description="Provides access to current and historical market quotes for financial assets using Yahoo Finance.",
        routes=app.routes,
        servers=[
            {"url": "http://localhost:8000", "description": "Staging environment"}
        ],
    )
    openapi_schema["info"]["x-logo"] = {
        "url": "https://fastapi.tiangolo.com/img/logo-margin/logo-teal.png" # Placeholder logo
    }
    openapi_schema["tags"] = [
        {
            "name": "Quotes",
            "description": "Endpoints for retrieving asset price information.",
        }
    ]
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
