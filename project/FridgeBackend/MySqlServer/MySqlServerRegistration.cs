using FridgeBackend.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;

namespace FridgeBackend.MySqlServer;

public static class MySqlServerRegistration
{
    public static IServiceCollection AddFridgeMySql(this IServiceCollection services, IConfiguration cfg)
    {
        var cs = cfg.GetConnectionString("DefaultConnection")
                 ?? "Server=localhost;Port=3306;Database=Fridge;User Id=fridge_user;Password=fridge_pass;";

        // var serverVersion = ServerVersion.AutoDetect(cs);
        var serverVersion = ServerVersion.Create(new Version(8, 0, 36), ServerType.MySql);
        services.AddDbContext<DataContextBase>(opt =>
            opt.UseMySql(cs, serverVersion, b => b.MigrationsAssembly("FridgeBackend.MySqlServer")));

        return services;
    }
}
