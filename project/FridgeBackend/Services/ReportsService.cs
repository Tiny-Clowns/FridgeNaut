using FridgeBackend.Data;
using Microsoft.EntityFrameworkCore;

namespace FridgeBackend.Services;

public class ReportsService
{
    private readonly DataContextBase _db;
    public ReportsService(DataContextBase db) => _db = db;

    public async Task<object> SummaryAsync(string range, DateTime? start = null)
    {
        var startDt = start ?? DateTime.UtcNow.Date.AddDays(range == "monthly" ? -30 : -7);

        var list = await _db.Events.Where(e => e.OccurredAt >= startDt).ToListAsync();
        var cost = list.Where(e => e.DeltaQuantity > 0)
                       .Sum(e => e.UnitPriceAtEvent.HasValue ? (double)e.UnitPriceAtEvent.Value * e.DeltaQuantity : 0);
        var usage = -list.Where(e => e.DeltaQuantity < 0).Sum(e => e.DeltaQuantity);

        return new { start = startDt, range, totalCost = cost, totalUsage = usage };
    }
}
