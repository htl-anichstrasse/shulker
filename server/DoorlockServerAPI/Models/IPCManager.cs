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

        
        Queue<string> sendQueue = new Queue<string>();

        public void addToSendQueue(String toAdd)
        {
            Console.WriteLine("Adding something to sendqueue");
            sendQueue.Enqueue(toAdd);
        }

        private Socket startServer()
        {
            var socket = new Socket(AddressFamily.Unix, SocketType.Stream, ProtocolType.Unspecified);

            Console.WriteLine("Connecting to Server");
            socket.Connect(new UnixDomainSocketEndPoint("/tmp/toShulkerCore.sock"));
            Console.WriteLine("Connected");
            return socket;
        }


        public void SenderThread(Object data)
        {
            CancellationToken cancellationToken = (CancellationToken)data;

            Socket socket;
            socket = startServer();

            while (true)
            {
                Thread.Sleep(50);
                if (cancellationToken.IsCancellationRequested)
                {
                    socket.Close();
                    return;
                }

                if (sendQueue.Count != 0)
                {
                    var toSend = sendQueue.Dequeue();
                    var dataToSend = System.Text.Encoding.UTF8.GetBytes(toSend);
                    Console.WriteLine("Sending " + toSend);
                    socket.Send(dataToSend);
                    Console.WriteLine("sent!");
                }
                
            }
        }


        private static String listenerPath = "/tmp/toShulkerServer.sock";
        public void ListenerThread(Object data)
        {
            CancellationToken cancellationToken = (CancellationToken)data;

            // Func<string, bool> recieved = (Func<string, bool>)data;
            if (System.IO.File.Exists(listenerPath))
                System.IO.File.Delete(listenerPath);

            Socket socket = new Socket(AddressFamily.Unix, SocketType.Stream, ProtocolType.Unspecified);
            socket.Bind(new UnixDomainSocketEndPoint(listenerPath));

            socket.Listen(64);
            Console.WriteLine("Server started, waiting for client to connect...");

            cancellationToken.Register(() =>
            {
                socket.Close();
                Console.WriteLine("Stopping Listener Thread");
            });

            var s = socket.Accept();
            Console.WriteLine("Client connected");
            
            while (!cancellationToken.IsCancellationRequested)
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
