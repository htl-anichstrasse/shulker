using DoorlockServerAPI.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CredentialsController : Controller
    {
        [HttpGet]
        public async Task<ActionResult<List<Credential>>> GetAllCredentialsAsync(String session)
        {
            if (!SessionManager.getInstance().sessionValid(session))
            {
                return Unauthorized();
            }

            List<Credential> pins;
            
            try
            {
                 pins = await MessageWrapper.getAllPinsWithTimeoutASYNC();
            }
            catch
            {
                return StatusCode(500);
            }

            return pins;
        }

        
    }
}
