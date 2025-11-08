using FridgeBackend.Data.Enums;
using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FridgeBackend.Data.DTO;

public class InventoryEvent
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    [Required] public Guid ItemId { get; set; }
    [ForeignKey(nameof(ItemId))] public Item? Item { get; set; }
    public double DeltaQuantity { get; set; }
    public decimal? UnitPriceAtEvent { get; set; }
    public EventType Type { get; set; } = EventType.Adjust;
    public DateTime OccurredAt { get; set; } = DateTime.UtcNow;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
