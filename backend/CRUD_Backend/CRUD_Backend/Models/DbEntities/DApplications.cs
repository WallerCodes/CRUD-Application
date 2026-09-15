namespace CRUD_Backend.Models.DbEntities;

using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

[Serializable]
[Table("applications", Schema = "crud")]
public class DApplications
{
    [Key]
    [Column("applicationId")]
    public int ApplicationId { get; set; }

    [Column("application")]
    public string Application { get; set; }

    [Column("dateAdded")]
    public DateTime DateAdded { get; set; }

    [Column("userIdAdAdd")]
    public int UserIdAdAdded { get; set; }

    public DApplications()
    {
    }
}
