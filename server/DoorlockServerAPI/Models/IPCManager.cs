using DoorlockServerAPI.Controllers;
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Net.Sockets;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class IPCManager
    {
        // Singleton Pattern
        private static IPCManager instance = null;
        private IPCManager() { }
        public static IPCManager getInstance()
        {
            if (instance == null)
            {
                instance = new IPCManager();
            }
            return instance;
        }

        private static String path = "/tmp/toASP.sock";
        Queue<string> sendQueue = new Queue<string>();

        public void addToSendQueue(String toAdd)
        {
            Console.WriteLine("Adding something to sendqueue");
            sendQueue.Enqueue(toAdd);
        }

        public void SenderThread()
        {
            using (var socket = new Socket(AddressFamily.Unix, SocketType.Stream, ProtocolType.Unspecified))
            {
                socket.Connect(new UnixDomainSocketEndPoint(path));

                while (true)
                {
                    Thread.Sleep(100);

                    if (sendQueue.Count != 0)
                    {
                        var toSend = sendQueue.Dequeue();
                        var dataToSend = System.Text.Encoding.UTF8.GetBytes(toSend);
                        Console.WriteLine("Sending " + toSend);
                        socket.Send(dataToSend);
                    }
                }
            }
        }



        public void ListenerThread()
        {
            // Func<string, bool> recieved = (Func<string, bool>)data;
            if (System.IO.File.Exists(path))
                System.IO.File.Delete(path);

            Socket socket = new Socket(AddressFamily.Unix, SocketType.Stream, ProtocolType.Unspecified);
            socket.Bind(new UnixDomainSocketEndPoint(path));

            socket.Listen(64);
            Console.WriteLine("Server started, waiting for client to connect...");

            var s = socket.Accept();
            Console.WriteLine("Client connected");
            
            while (true)
            {
                var buffer = new byte[1024];
                var numberOfBytesReceived = s.Receive(buffer, 0, buffer.Length, SocketFlags.None);
                var message = System.Text.Encoding.UTF8.GetString(buffer, 0, numberOfBytesReceived);

                //Console.WriteLine($"Received: {message}");
                MessageManager.newMessage(message);
            }
            
        }
    }
}
