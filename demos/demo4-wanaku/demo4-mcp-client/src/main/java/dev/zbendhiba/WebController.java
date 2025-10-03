package dev.zbendhiba;

import io.quarkus.qute.Template;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/")
public class WebController {

    @Inject
    Template dashboard;

    @GET
    @Produces(MediaType.TEXT_HTML)
    public String dashboard() {
        return dashboard.render();
    }
}
