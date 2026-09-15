namespace CRUD_Backend.Models.DbEntities;

using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

[Serializable]
[Table("userRoles", Schema = "crud")]
public class DUserRoles
{
    [Key]
    [Column("userId")]
    public int UserId { get; set; }

    [Column("roleId")]
    public int RoleId { get; set; }

    [Column("applicationId")]
    public int ApplicationId { get; set; }

    public DUserRoles()
    {
    }
}
