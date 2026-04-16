using CafeOrderManagement.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CafeOrderManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TablesController : ControllerBase
{
    private readonly AppDbContext _context;

    public TablesController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAllTables()
    {
        var tables = await _context.CafeTables
            .Select(t => new
            {
                t.TableId,
                t.TableNumber,
                t.Capacity,
                t.IsActive
            })
            .OrderBy(t => t.TableNumber)
            .ToListAsync();

        return Ok(tables);
    }

    [HttpGet("active")]
    public async Task<IActionResult> GetActiveTables()
    {
        var tables = await _context.CafeTables
            .Where(t => t.IsActive)
            .Select(t => new
            {
                t.TableId,
                t.TableNumber,
                t.Capacity
            })
            .OrderBy(t => t.TableNumber)
            .ToListAsync();

        return Ok(tables);
    }
}