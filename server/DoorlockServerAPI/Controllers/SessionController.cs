using DoorlockServerAPI.Models;
using DoorlockServerAPI.Models.db;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class SessionController : ControllerBase
    {
        DoorlockContext _context = new DoorlockContext();

        [HttpPost]
        [Route("getSession/{uuid}/{secret}")]
        public String createSession(String secret)
        {
            // toDo: validate secret

            Session newSession = new Session(DateTime.Now + TimeSpan.FromMinutes(20));
            SessionManager.getInstance().addSession(newSession);
            return newSession.SessionId;
        }
    }
}
