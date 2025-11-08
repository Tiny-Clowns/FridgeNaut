using FridgeBackend.Data;
using FridgeBackend.Data.DTO;
using FridgeBackend.Services;
using Microsoft.AspNetCore.Mvc;

namespace FridgeBackend.Server.Api;

[ApiController]
[Route("api/[controller]")]
public class EventsController : ControllerBase
{
    private readonly DataContextBase _db;
    private readonly ReportsService _reports;
    public EventsController(DataContextBase db, ReportsService reports)
    {
        _db = db;
        _reports = reports;
    }

    [HttpPost]
    public async Task<ActionResult<InventoryEvent>> Create(InventoryEvent e)
    {
        e.Id = e.Id == Guid.Empty ? Guid.NewGuid() : e.Id;
        e.CreatedAt = DateTime.UtcNow;
        _db.Events.Add(e);

        var item = await _db.Items.FindAsync(e.ItemId);
        if (item != null)
        {
            item.Quantity += e.DeltaQuantity;
            item.UpdatedAt = DateTime.UtcNow;
        }

        await _db.SaveChangesAsync();
        return e;
    }

    [HttpGet("summary")]
    public async Task<object> Summary([FromQuery] string range = "weekly", [FromQuery] string? start = null)
    {
        DateTime? s = null;
        if (start != null && DateTime.TryParse(start, out var parsed)) s = parsed;
        return await _reports.SummaryAsync(range, s);
    }
}
