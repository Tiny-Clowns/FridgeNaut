using FridgeBackend.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Pomelo.EntityFrameworkCore.MySql.Infrastructure;

namespace FridgeBackend.MySqlServer;

public class DesignTimeFactory : IDesignTimeDbContextFactory<DataContextBase>
{
    public DataContextBase CreateDbContext(string[] args)
    {
        var cs = "Server=localhost;Port=3306;Database=Fridge;User Id=fridge_user;Password=fridge_pass;";
        var serverVersion = ServerVersion.Create(new Version(8, 0, 36), ServerType.MySql);
        var options = new DbContextOptionsBuilder<DataContextBase>()
            .UseMySql(cs, serverVersion, b => b.MigrationsAssembly("FridgeBackend.MySqlServer"))
            .Options;

        return new DataContextBase(options);
    }
}
