using CRUD_Backend.Models.DbEntities;
using Microsoft.EntityFrameworkCore;

namespace CRUD_Backend.Properties.Database
{
    public class CrudDbContext : DbContext
    {
        public DbSet<DUser> Users { get; set; }

        public CrudDbContext(DbContextOptions<CrudDbContext> options)
        : base(options)
        {
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            ModelUser(modelBuilder);
        }

        private void ModelUser(ModelBuilder modelBuilder)
        {
            //modelBuilder.Entity<DUser>().ToTable("crud.users");

            modelBuilder.Entity<DUser>().Property(x => x.UserId).HasColumnName("userId");
            modelBuilder.Entity<DUser>().Property(x => x.IsDeleted).HasColumnName("deleted");
            modelBuilder.Entity<DUser>().Property(x => x.Password).HasColumnName("password");
            modelBuilder.Entity<DUser>().Property(x => x.Disabled).HasColumnName("disabled");
            modelBuilder.Entity<DUser>().Property(x => x.IsSuperAdmin).HasColumnName("isSuperAdmin");
            modelBuilder.Entity<DUser>().Property(x => x.IsUsanUser).HasColumnName("isUsanUser");
            modelBuilder.Entity<DUser>().Property(x => x.LastLoginDate).HasColumnName("lastLoginDate");
            modelBuilder.Entity<DUser>().Property(x => x.Locked).HasColumnName("locked");
            modelBuilder.Entity<DUser>().Property(x => x.FailedLoginAttempts).HasColumnName("failedLoginAttempts");
            modelBuilder.Entity<DUser>().Property(x => x.LastPasswordChangeDate).HasColumnName("lastPasswordChangeDate");
            modelBuilder.Entity<DUser>().Property(x => x.ForceChangePassword).HasColumnName("forceChangePassword");
            modelBuilder.Entity<DUser>().Property(x => x.DateAdded).HasColumnName("dateAdded");
        }
    }
}
