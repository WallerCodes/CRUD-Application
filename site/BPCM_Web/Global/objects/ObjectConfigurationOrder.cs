/// <summary>
/// Summary description for ObjectConfigurationOrder
/// </summary>
public class ObjectConfigurationOrder
{
    public int configurationId;
    public int order;

    public ObjectConfigurationOrder()
    {

    }

    public ObjectConfigurationOrder(int configurationId, int order)
    {
        this.configurationId = configurationId;
        this.order = order;
    }
}