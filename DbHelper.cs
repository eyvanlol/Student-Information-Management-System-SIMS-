using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace StudentManagementSystem
{
    /// <summary>
    /// Database helper for SQL Server (LocalDB).
    /// Connection string "SIMSConnection" lives in Web.config.
    ///
    ///   GetConnection()              - hand back an open-able SqlConnection.
    ///   ExecuteQuery(sql)            - raw SELECT -> DataTable  (legacy; existing pages use this).
    ///   ExecuteQuery(sql, params)    - parameterised SELECT -> DataTable.
    ///   ExecuteNonQuery(sql, params) - parameterised INSERT/UPDATE/DELETE -> rows affected.
    ///   ExecuteScalar(sql, params)   - parameterised single-value query (COUNT, etc.).
    /// </summary>
    public static class DbHelper
    {
        public static SqlConnection GetConnection()
        {
            string cs = ConfigurationManager.ConnectionStrings["SIMSConnection"].ConnectionString;
            return new SqlConnection(cs);
        }

        // Legacy: runs a SELECT string and returns a DataTable.
        // Kept identical so existing pages still build and behave the same.
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

        // Parameterised SELECT -> DataTable.
        public static DataTable ExecuteQuery(string sql, params SqlParameter[] parameters)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                {
                    da.Fill(dt);
                }
            }
            return dt;
        }

        // Parameterised INSERT/UPDATE/DELETE -> number of rows affected.
        public static int ExecuteNonQuery(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        // Resolves the Head-of-Programme identity line ("Head of Programme, <area>")
        // so every admin page shows the same text as the dashboard instead of a
        // hardcoded "Administrator". Cached in Session, so the lookup runs at most
        // once per login and reflects any value saved on the dashboard.
        public static string GetRoleIdentity(System.Web.SessionState.HttpSessionState session)
        {
            if (session == null) return "Head of Programme";

            object cached = session["RoleIdentity"];
            if (cached != null && !string.IsNullOrEmpty(cached.ToString()))
                return cached.ToString();

            string identity = "Head of Programme";
            try
            {
                if (session["UserID"] != null)
                {
                    object o = ExecuteScalar(
                        "SELECT headOf FROM HOP_ADMIN WHERE adminID = @id",
                        new SqlParameter("@id", System.Convert.ToInt32(session["UserID"])));
                    string h = (o == null || o == System.DBNull.Value) ? "" : o.ToString();
                    if (!string.IsNullOrEmpty(h))
                        identity = "Head of Programme, " + h;
                }
            }
            catch
            {
                // headOf column not present yet -> keep default.
            }

            session["RoleIdentity"] = identity;
            return identity;
        }

        // Parameterised single-value query (e.g. COUNT(*), SCOPE_IDENTITY()).
        public static object ExecuteScalar(string sql, params SqlParameter[] parameters)
        {
            using (SqlConnection conn = GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                if (parameters != null) cmd.Parameters.AddRange(parameters);
                conn.Open();
                return cmd.ExecuteScalar();
            }
        }
    }
}