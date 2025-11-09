using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace FridgeBackend.MySqlServer.Migrations
{
    /// <inheritdoc />
    public partial class AddLowThresholdAndAlerts : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<double>(
                name: "LowThreshold",
                table: "Items",
                type: "double",
                nullable: false,
                defaultValue: 0.0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "LowThreshold",
                table: "Items");
        }
    }
}
