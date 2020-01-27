{
      "Key" : {
        "Id" : { "S" : "$util.urlEncode($input.params('namespace'))/$util.urlEncode($input.params('module'))/$util.urlEncode($input.params('provider'))" },
        "Version" : { "S" : "$util.urlEncode($input.params('version'))" }
      },
      "TableName" : "${dynamo_table_name}"
}