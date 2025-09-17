package dev.zbendhiba;

import java.util.List;
import java.util.Arrays;

import io.quarkiverse.mcp.server.Prompt;
import io.quarkiverse.mcp.server.PromptArg;
import io.quarkiverse.mcp.server.PromptMessage;
import io.quarkiverse.mcp.server.CompletePrompt;
import io.quarkiverse.mcp.server.CompleteArg;
import io.quarkiverse.mcp.server.TextContent;
import jakarta.inject.Inject;
import org.jboss.logging.Logger;

public class MyPrompts {

    @Inject
    Logger log;

    @Prompt(description = "Get a personalized greeting message.")
    PromptMessage greet(@PromptArg(description = "The person's name") String name) {
        log.info("Greet prompt called with name: " + name);
        String message = "Hello " + name + "! Welcome to the MCP server demo.";
        log.debug("Generated greeting message: " + message);
        return PromptMessage.withUserRole(new TextContent(message));
    }

    @CompletePrompt("greet")
    List<String> completeName(@CompleteArg(name = "name") String val) {
        log.debug("Complete prompt called for name with value: " + val);
        List<String> names = Arrays.asList("Alice", "Bob", "Charlie", "David", "Eve");
        List<String> filteredNames = names.stream()
                .filter(n -> n.toLowerCase().startsWith(val.toLowerCase()))
                .toList();
        log.debug("Filtered names: " + filteredNames);
        return filteredNames;
    }

}
