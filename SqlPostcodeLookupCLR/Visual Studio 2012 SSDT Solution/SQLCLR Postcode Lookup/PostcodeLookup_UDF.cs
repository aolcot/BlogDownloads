using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;
using System.Xml;


public partial class UserDefinedFunctions
{
    [Microsoft.SqlServer.Server.SqlFunction(
        DataAccess = DataAccessKind.None,
        SystemDataAccess = SystemDataAccessKind.None,
        FillRowMethodName="fillrow",
        TableDefinition=@"Postcode nvarchar(9)
                            , Latitude decimal(18, 15)
                            , Longitude decimal(18, 15)
                            , Easting decimal(10,1)
                            , Northing decimal(10,1)
                            , Geohash nvarchar(200)")]
    public static IEnumerable LookupPostcode(SqlString Postcode, SqlBoolean ThrowExceptions)
    {
        var PostcodeXml =new List<XmlDocument>();

        try
        {
            HttpWebRequest request = WebRequest.Create(string.Format("http://uk-postcodes.com/postcode/{0}.xml", Postcode.ToString())) as HttpWebRequest;

            using(HttpWebResponse response = request.GetResponse() as HttpWebResponse)
            {
                XmlDocument xml = new XmlDocument();
                xml.Load(response.GetResponseStream());
                PostcodeXml.Add(xml);
            }
        }
        catch(Exception e)
        {
            if((bool)ThrowExceptions)
            {
                throw(e);
            }
            else
            {
                XmlDocument xml = new XmlDocument();
                PostcodeXml.Add(xml);
            }
        }

        return PostcodeXml;
    }


    public static void fillrow(Object obj, out SqlString Postcode, out SqlDecimal Latitude, out SqlDecimal Longitude, out SqlDecimal Easting, out SqlDecimal Northing, out SqlString Geohash)
    {
        XmlDocument PostcodeXml = (XmlDocument)obj;
        Postcode = PostcodeXml.SelectSingleNode("/result/postcode") == null ? "Unknown": PostcodeXml.SelectSingleNode("/result/postcode").InnerText ;
        Latitude = PostcodeXml.SelectSingleNode("/result/geo/lat") == null ? SqlDecimal.Null : Convert.ToDecimal(PostcodeXml.SelectSingleNode("/result/geo/lat").InnerText);
        Longitude = PostcodeXml.SelectSingleNode("/result/geo/lng") == null ? SqlDecimal.Null : Convert.ToDecimal(PostcodeXml.SelectSingleNode("/result/geo/lng").InnerText);
        Easting = PostcodeXml.SelectSingleNode("/result/geo/easting") == null ? SqlDecimal.Null : Convert.ToDecimal(PostcodeXml.SelectSingleNode("/result/geo/easting").InnerText);
        Northing = PostcodeXml.SelectSingleNode("/result/geo/northing") == null ? SqlDecimal.Null : Convert.ToDecimal(PostcodeXml.SelectSingleNode("/result/geo/northing").InnerText);
        Geohash = PostcodeXml.SelectSingleNode("/result/geo/geohash") == null ? SqlString.Null : PostcodeXml.SelectSingleNode("/result/geo/geohash").InnerText;
    }
}
