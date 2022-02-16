﻿using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    /// <summary>
    /// The Message Manager Class always recieves the most recent message recieved from the socket
    /// 
    /// The functions to get Data from the server always queue something to send from the socket,
    /// then they loop and wait for a response by looking at the most recent recieved message
    /// </summary>
    public class MessageManager
    {
        private static String lastRecieved;

        public static bool newMessage(String recieved)
        {
            Console.WriteLine(recieved);
            lastRecieved = recieved;
            return true;
        }

        public static void lockDoor()
        {
            // send request
            Dictionary<String, String> dataToSend = new Dictionary<string, string>();
            dataToSend["request"] = "LOCK";
            IPCManager.getInstance().addToSendQueue(JsonConvert.SerializeObject(dataToSend));
        }
        
        public static void unlockDoor()
        {
            // send request
            Dictionary<String, String> dataToSend = new Dictionary<string, string>();
            dataToSend["request"] = "UNLOCK";
            IPCManager.getInstance().addToSendQueue(JsonConvert.SerializeObject(dataToSend));
        }

        public static Task<bool> isAdminCredentialValidASYNC(CancellationToken cancellationToken, String secret)
        {
            // send request
            Dictionary<String, String> dataToSend = new Dictionary<string, string>();
            dataToSend["request"] = "CHECK ADMIN CREDENTIAL";
            dataToSend["secret"] = secret;
            IPCManager.getInstance().addToSendQueue(JsonConvert.SerializeObject(dataToSend));

            // wait for response
            while (true)
            {
                Thread.Sleep(25);

                if (cancellationToken.IsCancellationRequested)
                {
                    throw new TimeoutException();
                }

                if (lastRecieved.Contains("ADMIN CREDENTIAL VALID"))
                {
                    return Task.FromResult(true);
                }
            }
        }

        public static Task<String> getAllPins(CancellationToken cancellationToken)
        {
            // send request for pins
            Dictionary<String, String> dataToSend = new Dictionary<string, string>();
            dataToSend["request"] = "GET ALL PINS";
            IPCManager.getInstance().addToSendQueue(JsonConvert.SerializeObject(dataToSend));

            // wait for response
            while (true)
            {
                Thread.Sleep(25);
             
                if (cancellationToken.IsCancellationRequested)
                {
                    throw new TimeoutException();
                }

                if (lastRecieved.Contains("pins"))
                {
                    return Task.FromResult(lastRecieved);
                }
            }
        }
    }
}