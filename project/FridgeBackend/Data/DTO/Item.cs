using System;
using System.ComponentModel.DataAnnotations;

namespace FridgeBackend.Data.DTO;

public class Item
{
    [Key] public Guid Id { get; set; } = Guid.NewGuid();
    [Required] public string Name { get; set; } = string.Empty;
    public double Quantity { get; set; } = 0;
    public string Unit { get; set; } = "pcs";
    public DateTime? ExpirationDate { get; set; }
    public decimal? PricePerUnit { get; set; }
    public bool ToBuy { get; set; } = false;
    public bool NotifyOnLow { get; set; } = true;
    public bool NotifyOnExpire { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public double LowThreshold { get; set; } = 1;
}
