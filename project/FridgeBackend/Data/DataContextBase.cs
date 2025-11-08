using FridgeBackend.Data.DTO;
using Microsoft.EntityFrameworkCore;

namespace FridgeBackend.Data;

public class DataContextBase : DbContext
{
    public DataContextBase(DbContextOptions<DataContextBase> options) : base(options) { }

    public DbSet<Item> Items => Set<Item>();
    public DbSet<InventoryEvent> Events => Set<InventoryEvent>();

    protected override void OnModelCreating(ModelBuilder mb)
    {
        mb.Entity<Item>().HasIndex(i => i.UpdatedAt);
        mb.Entity<InventoryEvent>().HasIndex(e => e.OccurredAt);
    }
}
