package dev.zbendhiba;

import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatterBuilder;

import io.quarkiverse.mcp.server.Tool;

public class QuarkusClockMcpServer {
    @Tool(description = "Give the current time")
    public String time() {
        ZonedDateTime now = ZonedDateTime.now();
        return now.toLocalTime().format(new DateTimeFormatterBuilder()
                .appendPattern("HH:mm:ss").toFormatter());
    }
}
