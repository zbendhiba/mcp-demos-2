package dev.zbendhiba;

import jakarta.inject.Inject;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import org.jboss.logging.Logger;

@Path("/api")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class DashboardController {

    @Inject
    Logger log;

    @Inject
    MyAiService myAiService;

    @POST
    @Path("/chat")
    public Response chat(String userMessage) {
        try {
            log.info("Received chat request: " + userMessage);
            
            String response = myAiService.chat(userMessage);
            
            log.info("AI response: " + response);
            
            return Response.ok()
                    .entity(new ChatResponse(response))
                    .build();
        } catch (Exception e) {
            log.error("Error processing chat request", e);
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(new ChatResponse("Sorry, I encountered an error: " + e.getMessage()))
                    .build();
        }
    }

    public static class ChatResponse {
        public String message;
        
        public ChatResponse(String message) {
            this.message = message;
        }
    }
}
