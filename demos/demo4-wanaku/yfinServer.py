#!/usr/bin/env python

from fastapi import FastAPI, HTTPException, Query, Path
from fastapi.openapi.utils import get_openapi
from pydantic import BaseModel, Field
from datetime import date, datetime, timedelta
import yfinance as yf
import pandas as pd
from typing import List, Optional, Dict, Any
import numpy as np

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

class ComparisonResult(BaseModel):
    symbol1: str
    symbol2: str
    symbol1_price: Optional[float] = None
    symbol2_price: Optional[float] = None
    price_difference: Optional[float] = None
    percentage_difference: Optional[float] = None
    symbol1_change: Optional[float] = None
    symbol2_change: Optional[float] = None
    error: Optional[str] = None

class TrendAnalysis(BaseModel):
    symbol: str
    current_price: Optional[float] = None
    trend_direction: Optional[str] = None  # "up", "down", "sideways"
    trend_strength: Optional[str] = None   # "strong", "moderate", "weak"
    support_level: Optional[float] = None
    resistance_level: Optional[float] = None
    volatility: Optional[float] = None
    error: Optional[str] = None

class PortfolioItem(BaseModel):
    symbol: str
    quantity: int
    target_percentage: Optional[float] = None

class PortfolioAnalysis(BaseModel):
    total_value: Optional[float] = None
    total_investment: Optional[float] = None
    total_gain_loss: Optional[float] = None
    total_gain_loss_percentage: Optional[float] = None
    diversification_score: Optional[float] = None
    risk_level: Optional[str] = None
    items: List[Dict[str, Any]] = []
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


@app.get("/quotes/compare/{symbol1}/{symbol2}", response_model=ComparisonResult, tags=["Analysis"])
async def compare_symbols(
    symbol1: str = Path(..., title="First Asset Symbol", description="First stock ticker symbol to compare"),
    symbol2: str = Path(..., title="Second Asset Symbol", description="Second stock ticker symbol to compare")
):
    """
    Compare two assets by their current prices and recent performance.
    """
    try:
        # Get current quotes for both symbols
        ticker1, error1 = get_ticker_info(symbol1)
        ticker2, error2 = get_ticker_info(symbol2)
        
        if error1:
            return ComparisonResult(symbol1=symbol1, symbol2=symbol2, error=f"Error with {symbol1}: {error1}")
        if error2:
            return ComparisonResult(symbol1=symbol1, symbol2=symbol2, error=f"Error with {symbol2}: {error2}")
        
        # Get current prices
        data1 = ticker1.history(period="2d")
        data2 = ticker2.history(period="2d")
        
        if data1.empty or data2.empty:
            return ComparisonResult(symbol1=symbol1, symbol2=symbol2, error="Unable to fetch current prices for comparison")
        
        price1 = data1.iloc[-1]["Close"]
        price2 = data2.iloc[-1]["Close"]
        
        # Calculate changes (1-day)
        change1 = ((price1 - data1.iloc[-2]["Close"]) / data1.iloc[-2]["Close"]) * 100 if len(data1) > 1 else 0
        change2 = ((price2 - data2.iloc[-2]["Close"]) / data2.iloc[-2]["Close"]) * 100 if len(data2) > 1 else 0
        
        # Calculate differences
        price_diff = price1 - price2
        percentage_diff = ((price1 - price2) / price2) * 100 if price2 != 0 else 0
        
        return ComparisonResult(
            symbol1=symbol1,
            symbol2=symbol2,
            symbol1_price=price1,
            symbol2_price=price2,
            price_difference=price_diff,
            percentage_difference=percentage_diff,
            symbol1_change=change1,
            symbol2_change=change2
        )
    except Exception as e:
        return ComparisonResult(symbol1=symbol1, symbol2=symbol2, error=f"Error comparing symbols: {str(e)}")


@app.get("/quotes/trend/{symbol}", response_model=TrendAnalysis, tags=["Analysis"])
async def analyze_trend(
    symbol: str = Path(..., title="Asset Symbol", description="Stock ticker symbol to analyze")
):
    """
    Analyze the trend of an asset based on recent price movements.
    """
    try:
        ticker, error_msg = get_ticker_info(symbol)
        if error_msg:
            return TrendAnalysis(symbol=symbol, error=error_msg)
        
        # Get 30 days of data for trend analysis
        data = ticker.history(period="1mo")
        if data.empty or len(data) < 10:
            return TrendAnalysis(symbol=symbol, error="Insufficient data for trend analysis")
        
        current_price = data.iloc[-1]["Close"]
        
        # Calculate simple moving averages
        sma_5 = data["Close"].tail(5).mean()
        sma_20 = data["Close"].tail(20).mean() if len(data) >= 20 else data["Close"].mean()
        
        # Determine trend direction
        if current_price > sma_5 > sma_20:
            trend_direction = "up"
            trend_strength = "strong" if (current_price - sma_20) / sma_20 > 0.05 else "moderate"
        elif current_price < sma_5 < sma_20:
            trend_direction = "down"
            trend_strength = "strong" if (sma_20 - current_price) / sma_20 > 0.05 else "moderate"
        else:
            trend_direction = "sideways"
            trend_strength = "weak"
        
        # Calculate support and resistance levels
        recent_highs = data["High"].tail(20)
        recent_lows = data["Low"].tail(20)
        resistance_level = recent_highs.max()
        support_level = recent_lows.min()
        
        # Calculate volatility (standard deviation of returns)
        returns = data["Close"].pct_change().dropna()
        volatility = returns.std() * 100  # Convert to percentage
        
        return TrendAnalysis(
            symbol=symbol,
            current_price=current_price,
            trend_direction=trend_direction,
            trend_strength=trend_strength,
            support_level=support_level,
            resistance_level=resistance_level,
            volatility=volatility
        )
    except Exception as e:
        return TrendAnalysis(symbol=symbol, error=f"Error analyzing trend: {str(e)}")


@app.post("/quotes/portfolio/calculate", response_model=PortfolioAnalysis, tags=["Portfolio"])
async def calculate_portfolio(portfolio_items: List[PortfolioItem]):
    """
    Calculate portfolio performance and analysis.
    """
    try:
        if not portfolio_items:
            return PortfolioAnalysis(error="Portfolio cannot be empty")
        
        total_investment = 0
        total_current_value = 0
        items_analysis = []
        
        for item in portfolio_items:
            ticker, error_msg = get_ticker_info(item.symbol)
            if error_msg:
                return PortfolioAnalysis(error=f"Error fetching data for {item.symbol}: {error_msg}")
            
            # Get current price
            data = ticker.history(period="2d")
            if data.empty:
                return PortfolioAnalysis(error=f"No data available for {item.symbol}")
            
            current_price = data.iloc[-1]["Close"]
            
            # Calculate values
            item_value = item.quantity * current_price
            total_current_value += item_value
            
            # For demo purposes, assume initial investment was 10% less than current value
            initial_price = current_price * 0.9
            item_investment = item.quantity * initial_price
            total_investment += item_investment
            
            # Calculate gain/loss for this item
            item_gain_loss = item_value - item_investment
            item_gain_loss_pct = (item_gain_loss / item_investment) * 100 if item_investment > 0 else 0
            
            items_analysis.append({
                "symbol": item.symbol,
                "quantity": item.quantity,
                "current_price": current_price,
                "current_value": item_value,
                "initial_investment": item_investment,
                "gain_loss": item_gain_loss,
                "gain_loss_percentage": item_gain_loss_pct
            })
        
        # Calculate overall portfolio metrics
        total_gain_loss = total_current_value - total_investment
        total_gain_loss_pct = (total_gain_loss / total_investment) * 100 if total_investment > 0 else 0
        
        # Simple diversification score (based on number of different assets)
        diversification_score = min(len(portfolio_items) * 20, 100)  # Max 100 for 5+ assets
        
        # Simple risk assessment based on volatility
        avg_volatility = 0
        for item in portfolio_items:
            ticker, _ = get_ticker_info(item.symbol)
            if ticker:
                data = ticker.history(period="1mo")
                if not data.empty:
                    returns = data["Close"].pct_change().dropna()
                    avg_volatility += returns.std() * 100
        
        avg_volatility = avg_volatility / len(portfolio_items)
        risk_level = "high" if avg_volatility > 3 else "medium" if avg_volatility > 1.5 else "low"
        
        return PortfolioAnalysis(
            total_value=total_current_value,
            total_investment=total_investment,
            total_gain_loss=total_gain_loss,
            total_gain_loss_percentage=total_gain_loss_pct,
            diversification_score=diversification_score,
            risk_level=risk_level,
            items=items_analysis
        )
    except Exception as e:
        return PortfolioAnalysis(error=f"Error calculating portfolio: {str(e)}")


@app.get("/quotes/sectors", tags=["Market Data"])
async def get_sector_data():
    """
    Get basic sector information and popular stocks in each sector.
    """
    sectors = {
        "Technology": ["AAPL", "MSFT", "GOOGL", "AMZN", "META"],
        "Healthcare": ["JNJ", "PFE", "UNH", "ABBV", "MRK"],
        "Financial": ["JPM", "BAC", "WFC", "GS", "MS"],
        "Consumer": ["KO", "PEP", "WMT", "PG", "NKE"],
        "Energy": ["XOM", "CVX", "COP", "EOG", "SLB"]
    }
    
    sector_data = {}
    for sector, symbols in sectors.items():
        sector_data[sector] = []
        for symbol in symbols:
            try:
                ticker, error_msg = get_ticker_info(symbol)
                if not error_msg and ticker:
                    data = ticker.history(period="2d")
                    if not data.empty:
                        current_price = data.iloc[-1]["Close"]
                        change = ((current_price - data.iloc[-2]["Close"]) / data.iloc[-2]["Close"]) * 100 if len(data) > 1 else 0
                        sector_data[sector].append({
                            "symbol": symbol,
                            "price": current_price,
                            "change_percentage": change
                        })
            except:
                continue
    
    return {"sectors": sector_data}



# --- OpenAPI Customization ---
def custom_openapi():
    if app.openapi_schema:
        return app.openapi_schema
    openapi_schema = get_openapi(
        openapi_version="3.0.2",
        title="Smart Finance API",
        version="1.0.0",
        description="Smart Finance API: Provides comprehensive financial data, analysis, portfolio management, and market insights using Yahoo Finance data.",
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
        },
        {
            "name": "Analysis",
            "description": "Endpoints for financial analysis and comparisons.",
        },
        {
            "name": "Portfolio",
            "description": "Endpoints for portfolio management and analysis.",
        },
        {
            "name": "Market Data",
            "description": "Endpoints for market-wide data and sector information.",
        },
    ]
    app.openapi_schema = openapi_schema
    return app.openapi_schema

app.openapi = custom_openapi

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
