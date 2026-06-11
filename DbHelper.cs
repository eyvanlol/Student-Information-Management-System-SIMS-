using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    /// <summary>
    /// Database helper for SQL Server (LocalDB).
    /// - GetConnection(): hand back an open-able SqlConnection.
    /// - ExecuteQuery(): run a SELECT and return the rows as a DataTable.
    /// Connection string "SIMSConnection" lives in Web.config.
    /// </summary>
    public static class DbHelper
    {
        public static SqlConnection GetConnection()
        {
            string cs = ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;
            return new SqlConnection(cs);
        }

        // Runs a SELECT statement and returns the result as a DataTable.
        public static DataTable ExecuteQuery(string sql)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = GetConnection())
            using (SqlDataAdapter da = new SqlDataAdapter(sql, conn))
            {
                da.Fill(dt);
            }
            return dt;
        }
    }
}