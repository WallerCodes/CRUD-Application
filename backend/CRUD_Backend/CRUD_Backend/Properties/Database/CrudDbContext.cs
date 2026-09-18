using CRUD_Backend.Models.DbEntities;
using Microsoft.EntityFrameworkCore;

namespace CRUD_Backend.Properties.Database
{
    public class CrudDbContext : DbContext
    {
        public DbSet<DUsers> Users { get; set; }
        public DbSet<DUserRoles> UserRoles { get; set; }
        public DbSet<DRoles> Roles { get; set; }
        public DbSet<DApplications> Applications { get; set; }

        // custom as this is not a representation of all configs, but rather the ones the caller can see
        public DbSet<DConfigs> GetConfigurationsResults { get; set; }

        public CrudDbContext(DbContextOptions<CrudDbContext> options)
        : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
        }
       
    }
}
