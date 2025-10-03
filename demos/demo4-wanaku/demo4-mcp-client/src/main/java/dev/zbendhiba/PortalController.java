package dev.zbendhiba;

import io.quarkus.qute.Template;
import jakarta.inject.Inject;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/")
public class PortalController {

    @Inject
    Template portal;

    @Inject
    Template dashboard;

    @Inject
    Template demo1;

    @GET
    @Produces(MediaType.TEXT_HTML)
    public String portal() {
        return portal.render();
    }

    @GET
    @Path("/demo1")
    @Produces(MediaType.TEXT_HTML)
    public String demo1() {
        return demo1.render();
    }

    @GET
    @Path("/demo2")
    @Produces(MediaType.TEXT_HTML)
    public String demo2() {
        return dashboard.render();
    }

    @GET
    @Path("/demo3")
    @Produces(MediaType.TEXT_HTML)
    public String demo3() {
        // Demo 3 coming soon - redirect to portal
        return portal.render();
    }
}
