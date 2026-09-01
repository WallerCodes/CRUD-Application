using BPCM;

/// <summary>
/// Holds query table join information
/// </summary>
public class UsanTableJoin
{
    public string JoinTable; // the table you are trying to join
    public string JoinColumn;
    public string MainTable;
    public string MainColumn;
    public UsanCommand SubQuery;
    public UsanJoinType JoinType;


    public UsanTableJoin(string JoinTable, string JoinColumn, string MainTable, string MainColumn, UsanJoinType joinType = UsanJoinType.INNER)
    {
        this.JoinTable = JoinTable;
        this.JoinColumn = JoinColumn;
        this.MainTable = MainTable;
        this.MainColumn = MainColumn;
        this.JoinType = joinType;
        SubQuery = null;
    }
}