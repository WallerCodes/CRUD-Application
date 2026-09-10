using CRUD_Backend.Models.DbEntities;
using CRUD_Backend.Models.DTOs.Requests;
using CRUD_Backend.Properties.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CRUD_Backend.Controllers;

[ApiController]
[Route("api/database")]
public class DatabaseController : ControllerBase
{

    private readonly ILogger<DatabaseController> _logger;
    private readonly CrudDbContext _dbContext;

    public DatabaseController(ILogger<DatabaseController> logger, CrudDbContext dbContext)
    {
        _logger = logger;
        _dbContext = dbContext;
    }

    [HttpPost("ValidateLogin")]
    public ActionResult<DUser> ValidateLogin([FromBody] UserRequestDTO request)
    {
        string? username = request.Username;
        if (string.IsNullOrEmpty(request.Username)) return BadRequest("Username must not be empty or null");

        string? password = request.Password;
        if (string.IsNullOrEmpty(request.Password)) return BadRequest("Password must not be empty or null");

        var user = _dbContext.Users.Where((u) => u.Username == username);
        var userO = user.FirstOrDefault();
        if (userO is null) return Ok("User not found.");

        Console.WriteLine("request password: {0}", password);
        Console.WriteLine("db user password: {0}", userO.Password);

        return Ok(new DUser() { UserId = 1 });
    }
}

