using CRUD_Backend.Models.DbEntities;
using CRUD_Backend.Models.DTOs.Requests;
using CRUD_Backend.Models.DTOs.Responses;
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
    public ActionResult<DUsers> ValidateLogin([FromBody] UserRequestDTO request)
    {
        // should not happen due to form validation on the front end
        string? username = request.Username;
        if (string.IsNullOrEmpty(request.Username)) return BadRequest("Username must not be empty or null");

        string? password = request.Password;
        if (string.IsNullOrEmpty(request.Password)) return BadRequest("Password must not be empty or null");

        var userQueryable = _dbContext.Users.Where((u) => u.Username == username);
        var user = userQueryable.FirstOrDefault();

        if (user is null) return NotFound();

        if (!user.Password.Equals(request.Password)) return Unauthorized();

        //var roles = _dbContext.Users.Join(
        //        _dbContext.UserRoles,
        //        users => users.UserId, // left table
        //        roles => roles.UserId, // right table
        //        (users, roles) => new { DUsers = users, DUserRoles = roles } // condition?
        //    ).ToList();

        var urs = (
            from dbUsers in _dbContext.Users
            join userRoles in _dbContext.UserRoles
                on dbUsers.UserId equals userRoles.UserId
            join roles in _dbContext.Roles
                on userRoles.RoleId equals roles.RoleId
            join applications in _dbContext.Applications
                on userRoles.ApplicationId equals applications.ApplicationId
            select new ObjectUserRole
            {
                Username = dbUsers.Username,
                Application = applications.Application,
                Role = roles.RoleName
            }
        ).ToList();

        return Ok(
            new UserResponseDTO()
            {
                UserId = user.UserId,
                Username = user.Username,

                IsDeleted = user.IsDeleted,
                IsDisabled = user.IsDeleted,
                IsSuperAdmin = user.IsSuperAdmin,
                IsUsanUser = user.IsUsanUser,
                IsLocked = user.IsLocked,

                ForceChangePassword = user.ForceChangePassword,

                FailedLoginAttempts = user.FailedLoginAttempts,

                LastLoginDate = user.LastLoginDate,
                LastPasswordChangeDate = user.LastPasswordChangeDate,
                DateAdded = user.DateAdded,

                UserRoles = urs,
                Success = true
            }
        );
    }

    [HttpPost("GetConfigurations")]
    public ActionResult<List<DConfigs>> GetConfigurations([FromBody] GetConfigsRequestDTO request)
    {       
        FormattableString sql = $"""
            EXEC crud.GetConfigurations
                {(string.IsNullOrEmpty(request.UserName) ? null : request.UserName)},
                {(string.IsNullOrEmpty(request.Application) ? null : request.Application)},
                {(string.IsNullOrEmpty(request.Language) ? null : request.Language)},
                {(string.IsNullOrEmpty(request.DNIS) ? null : request.DNIS)},
                {(string.IsNullOrEmpty(request.DestinationPhoneNumber) ? null : request.DestinationPhoneNumber)},
                {(string.IsNullOrEmpty(request.Peg) ? null : request.Peg)},
                {(string.IsNullOrEmpty(request.Rank) ? null : request.Rank)},
                {(string.IsNullOrEmpty(request.OfferID) ? null : request.OfferID)},
                {(string.IsNullOrEmpty(request.OfferType) ? null : request.OfferType)},
                {(string.IsNullOrEmpty(request.LastModifiedBy) ? null : request.LastModifiedBy)},
                {request.LastModifiedDate}
        """;

        var configs = _dbContext.GetConfigurationsResults
        .FromSqlInterpolated(sql)
        .ToList();

        return Ok(configs);
    }
}

