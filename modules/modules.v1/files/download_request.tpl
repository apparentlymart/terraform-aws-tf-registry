{
      TableName = ${dynamo_table_name}
      Key : {
        Id      = { S = "$util.escapeJavaScript($input.params('namespace'))/$util.escapeJavaScript($input.params('module'))/$util.escapeJavaScript($input.params('provider'))" }
        Version = { S = "$util.escapeJavaScript($input.params('version'))" }
      }
}
