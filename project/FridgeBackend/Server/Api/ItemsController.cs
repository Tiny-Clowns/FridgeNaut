using FridgeBackend.Data;
using FridgeBackend.Data.DTO;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FridgeBackend.Server.Api;

[ApiController]
[Route("api/[controller]")]
public class ItemsController : ControllerBase
{
    private readonly DataContextBase _db;
    public ItemsController(DataContextBase db) => _db = db;

    [HttpGet]
    public async Task<IEnumerable<Item>> GetAll() =>
        await _db.Items.OrderBy(i => i.Name).ToListAsync();

    [HttpGet("{id}")]
    public async Task<ActionResult<Item>> Get(Guid id) =>
        await _db.Items.FindAsync(id) is { } it ? it : NotFound();

    [HttpPost]
    public async Task<ActionResult<Item>> Create(Item item)
    {
        item.Id = item.Id == Guid.Empty ? Guid.NewGuid() : item.Id;
        item.CreatedAt = item.UpdatedAt = DateTime.UtcNow;
        _db.Items.Add(item);
        await _db.SaveChangesAsync();
        return CreatedAtAction(nameof(Get), new { id = item.Id }, item);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, Item input)
    {
        var it = await _db.Items.FindAsync(id);
        if (it is null) return NotFound();

        it.Name = input.Name;
        it.Quantity = input.Quantity;
        it.Unit = input.Unit;
        it.ExpirationDate = input.ExpirationDate;
        it.PricePerUnit = input.PricePerUnit;
        it.ToBuy = input.ToBuy;
        it.NotifyOnLow = input.NotifyOnLow;
        it.NotifyOnExpire = input.NotifyOnExpire;
        it.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var it = await _db.Items.FindAsync(id);
        if (it is null) return NotFound();

        _db.Items.Remove(it);
        await _db.SaveChangesAsync();
        return NoContent();
    }

    [HttpGet("since/{isoUtc}")]
    public async Task<ActionResult<IEnumerable<Item>>> Since(string isoUtc)
    {
        if (!DateTime.TryParse(isoUtc, out var ts)) return BadRequest("invalid timestamp");
        return await _db.Items.Where(i => i.UpdatedAt >= ts).ToListAsync();
    }

    // add at bottom of ItemsController
    [HttpGet("alerts")]
    public async Task<object> Alerts([FromQuery] int days = 3, [FromQuery] double? threshold = null)
    {
        var now = DateTime.UtcNow;
        var soon = now.AddDays(days);

        var q = _db.Items.AsQueryable();

        // Low stock: quantity <= threshold (per-item LowThreshold if none supplied)
        var low = await q.Where(i => i.Quantity <= (threshold ?? i.LowThreshold))
                        .OrderBy(i => i.Quantity).ToListAsync();

        // Expiring soon
        var expSoon = await q.Where(i => i.ExpirationDate != null && i.ExpirationDate <= soon)
                            .OrderBy(i => i.ExpirationDate).ToListAsync();

        // Out of stock
        var outOfStock = await q.Where(i => i.Quantity <= 0).OrderBy(i => i.Name).ToListAsync();

        // Planned to buy
        var toBuy = await q.Where(i => i.ToBuy).OrderBy(i => i.Name).ToListAsync();

        return new { low, expSoon, outOfStock, toBuy, now };
    }
}
