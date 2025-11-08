using FridgeBackend.MySqlServer;
using FridgeBackend.Services;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace FridgeBackend.Server;

public class Startup
{
    private readonly IConfiguration _cfg;
    public Startup(IConfiguration cfg) => _cfg = cfg;

    public void ConfigureServices(IServiceCollection services)
    {
        services.AddControllers();
        services.AddEndpointsApiExplorer();
        services.AddSwaggerGen();
        services.AddCors(p => p.AddPolicy("AllowAll", b =>
            b.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

        services.AddFridgeMySql(_cfg);

        // App services
        services.AddScoped<ReportsService>();
    }

    public void Configure(IApplicationBuilder app, IHostEnvironment env)
    {
        app.UseCors("AllowAll");
        app.UseSwagger();
        app.UseSwaggerUI();

        app.UseRouting();
        app.UseAuthorization();
        app.UseEndpoints(endpoints => { endpoints.MapControllers(); });
    }
}
