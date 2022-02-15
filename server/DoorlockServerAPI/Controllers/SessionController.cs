﻿using DoorlockServerAPI.Models;
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

        [HttpGet]
        [Route("getToken/{secret}")]
        public async Task<IActionResult> getToken(String secret)
        {
            //bool secretValid = await MessageWrapper.checkAdminCredentialWithTimeoutASYNC(secret);
            //if (!secretValid)
            //{
            //    return BadRequest();
            //}
            Console.WriteLine("get token uk");
            Session newSession = new Session(DateTime.Now + TimeSpan.FromMinutes(20));
            SessionManager.getInstance().registerSession(newSession);
            return Ok(newSession.SessionId);
        }
    }
}
