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

        private static String listenerPath = "/tmp/toShulkerServer.sock";
        //private static String senderPath = "/tmp/toShulkerServer.sock";
        private static String senderPath = "/tmp/toShulkerCore.sock";

        public void addToSendQueue(String toAdd)
        {
            sendQueue.Enqueue(toAdd);
        }


        public void SenderThread(Object data)
        {
            CancellationToken cancellationToken = (CancellationToken)data;

            Socket socket = new Socket(AddressFamily.Unix, SocketType.Stream, ProtocolType.Unspecified);

            Console.WriteLine("Connecting to Server");
            while (!socket.Connected)
            {
                try
                {
                    socket.Connect(new UnixDomainSocketEndPoint(senderPath));
                    Console.WriteLine("Connected");
                }
                catch
                {
                    Console.WriteLine("Failed to connect to " + listenerPath + " Timeout 3 seconds");
                    Thread.Sleep(3000);
                }

            }

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
                }

            }
        }

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

            var s = socket.Accept();
            Console.WriteLine("Client connected");

            // loop forever
            while (true)
            {
                string dataRec = null;
                byte[] bytes = null;

                // loop for every message
                while (true)
                {
                    if (cancellationToken.IsCancellationRequested)
                    {
                        socket.Close();
                        return;
                    }

                    // sleep with cancellation Token check
                    cancellationToken.WaitHandle.WaitOne(TimeSpan.FromMilliseconds(30));

                    try
                    {
                        bytes = new byte[1024];
                        int bytesRec = s.Receive(bytes);
                        dataRec += Encoding.ASCII.GetString(bytes, 0, bytesRec);
                        if (dataRec.IndexOf("\n") > -1)
                        {
                            break;
                        }

                        byte[] msg = Encoding.ASCII.GetBytes(dataRec);
                        String message = Encoding.UTF8.GetString(msg, 0, msg.Length);
                        Console.WriteLine($"Received: {message}");
                        MessageManager.newMessage(message);
                    }
                    catch (TimeoutException e)
                    {
                        Console.WriteLine("Timeout Exception when recieving bytes from socket");
                        Console.WriteLine(e.StackTrace);
                    }
                    catch (Exception e)
                    {
                        Console.WriteLine("Other Exception when recieiving bytes from socket");
                        Console.WriteLine(e.StackTrace);
                    }
                    break;

                }


            }

        }
    }
}
