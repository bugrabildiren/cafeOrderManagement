using CafeOrderManagement.Api.Data;
using CafeOrderManagement.Api.Dtos;
using CafeOrderManagement.Api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CafeOrderManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class OrdersController : ControllerBase
{
    private readonly AppDbContext _context;

    public OrdersController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet("statuses")]
    public async Task<IActionResult> GetOrderStatuses()
    {
        var statuses = await _context.OrderStatuses
            .Select(s => new
            {
                statusId = s.StatusId,
                statusName = s.StatusName
            })
            .OrderBy(s => s.statusId)
            .ToListAsync();

        return Ok(statuses);
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActiveOrders()
    {
        var activeStatuses = new[] { "Pending", "Preparing", "Served" };

        var orders = await _context.Orders
            .Include(o => o.Table)
            .Include(o => o.Status)
            .Include(o => o.OrderItems)
            .Where(o => activeStatuses.Contains(o.Status.StatusName))
            .Select(o => new
            {
                o.OrderId,
                TableNumber = o.Table.TableNumber,
                Status = o.Status.StatusName,
                o.OrderCreatedAt,
                o.Notes,
                ItemCount = o.OrderItems.Count,
                TotalAmount = o.OrderItems.Sum(oi => oi.Quantity * oi.UnitPrice)
            })
            .OrderBy(o => o.TableNumber)
            .ToListAsync();

        return Ok(orders);
    }

    [HttpGet("by-status")]
    public async Task<IActionResult> GetOrdersByStatus([FromQuery] string[] statuses)
    {
        if (statuses is null || statuses.Length == 0)
            return BadRequest(new { message = "At least one status is required." });

        var orders = await _context.Orders
            .Include(o => o.Table)
            .Include(o => o.Status)
            .Include(o => o.OrderItems)
            .Where(o => statuses.Contains(o.Status.StatusName))
            .Select(o => new
            {
                o.OrderId,
                TableNumber = o.Table.TableNumber,
                Status = o.Status.StatusName,
                o.OrderCreatedAt,
                o.Notes,
                ItemCount = o.OrderItems.Count,
                TotalAmount = o.OrderItems.Sum(oi => oi.Quantity * oi.UnitPrice)
            })
            .OrderByDescending(o => o.OrderCreatedAt)
            .ToListAsync();

        return Ok(orders);
    }

    [HttpGet("{id:long}")]
    public async Task<IActionResult> GetOrderById(long id)
    {
        var order = await _context.Orders
            .Include(o => o.Table)
            .Include(o => o.Status)
            .Include(o => o.OrderItems)
                .ThenInclude(oi => oi.Product)
            .FirstOrDefaultAsync(o => o.OrderId == id);

        if (order is null)
            return NotFound(new { message = "Order not found." });

        var result = new
        {
            order.OrderId,
            TableNumber = order.Table.TableNumber,
            Status = order.Status.StatusName,
            order.OrderCreatedAt,
            order.Notes,
            Items = order.OrderItems.Select(oi => new
            {
                oi.OrderItemId,
                oi.ProductId,
                ProductName = oi.Product.ProductName,
                oi.Quantity,
                oi.UnitPrice,
                LineTotal = oi.Quantity * oi.UnitPrice
            }),
            TotalAmount = order.OrderItems.Sum(oi => oi.Quantity * oi.UnitPrice)
        };

        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> CreateOrder([FromBody] CreateOrderDto dto)
    {
        var pendingStatus = await _context.OrderStatuses
            .FirstOrDefaultAsync(s => s.StatusName == "Pending");

        if (pendingStatus is null)
            return BadRequest(new { message = "Pending status not found." });

        var order = new Order
        {
            TableId = dto.TableId,
            StatusId = pendingStatus.StatusId,
            Notes = dto.Notes,
            OrderCreatedAt = DateTime.UtcNow
        };

        _context.Orders.Add(order);

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.InnerException?.Message ?? ex.Message });
        }

        return CreatedAtAction(nameof(GetOrderById), new { id = order.OrderId }, new
        {
            order.OrderId,
            order.TableId,
            order.StatusId,
            order.OrderCreatedAt,
            order.Notes
        });
    }

    [HttpPost("{id:long}/items")]
    public async Task<IActionResult> AddOrderItem(long id, [FromBody] AddOrderItemDto dto)
    {
        if (dto.Quantity < 1)
            return BadRequest(new { message = "Quantity must be at least 1." });

        var orderExists = await _context.Orders.AnyAsync(o => o.OrderId == id);
        if (!orderExists)
            return NotFound(new { message = "Order not found." });

        try
        {
            await _context.Database.ExecuteSqlInterpolatedAsync(
                $@"SELECT add_order_item({id}, {dto.ProductId}, {dto.Quantity})");
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.InnerException?.Message ?? ex.Message });
        }

        return Ok(new { message = "Item added successfully." });
    }

    [HttpPatch("{id:long}/status")]
    public async Task<IActionResult> UpdateOrderStatus(long id, [FromBody] UpdateOrderStatusDto dto)
    {
        var order = await _context.Orders.FirstOrDefaultAsync(o => o.OrderId == id);

        if (order is null)
            return NotFound(new { message = "Order not found." });

        order.StatusId = dto.StatusId;

        try
        {
            await _context.SaveChangesAsync();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.InnerException?.Message ?? ex.Message });
        }

        return Ok(new { message = "Order status updated successfully." });
    }
}
