﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class MessageWrapper
    {
        private static int timeoutMillis = 500;

        public static void lockDoor()
        {
            MessageManager.lockDoor();
        }
        
        public static void unlockDoor()
        {
            MessageManager.unlockDoor();
        }

        public static async Task<string> getAllPinsWithTimeoutASYNC()
        {
            try
            {
                CancellationTokenSource cancelSource = new CancellationTokenSource();
                cancelSource.CancelAfter(TimeSpan.FromMilliseconds(timeoutMillis));
                CancellationToken cancelToken = cancelSource.Token;

                return await MessageManager.getAllPins(cancelToken);
            } catch
            {
                return "error";
            }
        }

        public static async Task<bool> checkAdminCredentialWithTimeoutASYNC(String secret)
        {
            try
            {
                CancellationTokenSource cancelSource = new CancellationTokenSource();
                cancelSource.CancelAfter(TimeSpan.FromMilliseconds(timeoutMillis));
                CancellationToken cancelToken = cancelSource.Token;

                return await MessageManager.isAdminCredentialValidASYNC(cancelToken, secret);
            }
            catch
            {
                return false;
            }
        }
    }
}