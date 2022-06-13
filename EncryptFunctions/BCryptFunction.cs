using System.IO;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Azure.WebJobs.Extensions.OpenApi.Core.Attributes;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using Newtonsoft.Json;

namespace BCryptFunction.Function
{
    public class BCryptFunction
    {
        private readonly ILogger<BCryptFunction> _logger;

        public BCryptFunction(ILogger<BCryptFunction> log)
        {
            _logger = log;
        }

        [FunctionName("BCryptFunction")]
        [OpenApiOperation(operationId: "Run", tags: new[] { "Encrypt" })]
        [OpenApiResponseWithBody(statusCode: HttpStatusCode.OK, contentType: "text/plain", bodyType: typeof(string), Description = "The OK response")]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req)
        {
            var password = "My_P4$$word!";
            var workFactor = 13;
            string passwordHash = BCrypt.Net.BCrypt.HashPassword(password, workFactor);
            bool verified = BCrypt.Net.BCrypt.Verify(password, passwordHash);
            return new OkObjectResult(verified);
        }
    }
}

