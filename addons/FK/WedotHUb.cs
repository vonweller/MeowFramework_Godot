using System;
using System.Collections.Generic;
using System.Reflection;
using System.Threading.Tasks;
using Godot;

namespace Panty;
    public interface ISingleton { void Init(); }
    public abstract class Singleton<S> where S : class, ISingleton
    {
        private static S mInstance;
        public static S GetIns()
        {
            if (mInstance == null)
            {
                var ctor = Array.Find(
                    typeof(S).GetConstructors(BindingFlags.Instance | BindingFlags.NonPublic),
                    c => c.GetParameters().Length == 0);
                if (ctor == null) throw new Exception($"{typeof(S).Name}缺少私有构造函数");
                mInstance = ctor.Invoke(null) as S;
                mInstance.Init();
            }
            return mInstance;
        }
    }
    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct | AttributeTargets.Method, Inherited = false)]
    public class EmptyAttribute : Attribute { }
    [AttributeUsage(AttributeTargets.Field, AllowMultiple = false)]
    public class FindComponentAttribute : Attribute
    {
        public string GoName;
        public bool GetChild;
        /// <summary>
        /// 查找游戏物体组件的特性
        /// </summary>
        /// <param name="goName">游戏物体名字</param>
        /// <param name="getChild">
        /// true => 查找对应名字对象的下一级子物体 通常名字为父物体名字 类型为子物体
        /// false => 查找对应名字的对象 通常会将类型和名字对应</param>
        public FindComponentAttribute(string goName, bool getChild = true)
        {
            GoName = goName;
            GetChild = getChild;
        }
    }
    public partial class RmvTrigger : Node
    {
        private readonly Stack<IRmv> rmvs = new Stack<IRmv>();
        public void Add(IRmv rmv) => rmvs.Push(rmv);
        protected void RmvAll()
        {
            while (rmvs.Count > 0) rmvs.Pop().Do();
        }
    }
    public partial class RmvOnDestroyTrigger : RmvTrigger
    {
        private void OnDestroy() => RmvAll();
    }
    public partial class RmvOnDisableTrigger : RmvTrigger
    {
        private void OnDisable() => RmvAll();
    }
    public partial class WeDotTimeInfo : Node,ITimeInfo
    {
        /*float ITimeInfo.deltaTime =>(float)GetProcessDeltaTime();
        float ITimeInfo.timeScale =>(float)Engine.TimeScale;
        float ITimeInfo.unscaledDeltaTime =>(float)GetPhysicsProcessDeltaTime();*/
        public float deltaTime  { get; set; }
        public float timeScale { get; set; }
        public float unscaledDeltaTime  { get; set; }
       public WeDotTimeInfo(float deltaTime, float unscaledDeltaTime,float timeScale)
        {
            this.deltaTime = deltaTime;
            this.unscaledDeltaTime = unscaledDeltaTime;
            this.timeScale = timeScale;
        }
        
    }

    public static partial class HubEx
    {
        /// <summary>
        /// 获取系统层 Module 的别名
        /// </summary>
        public static S GetSystem<S>(this IPermissionProvider self) where S : class, IModule => self.Hub.Module<S>();
        /// <summary>
        /// 获取模型层 Module 的别名
        /// </summary>
        public static M GetModel<M>(this IPermissionProvider self) where M : class, IModule => self.Hub.Module<M>();
        /// <summary>
        /// 标记为物体被销毁时注销
        /// </summary>
        public static void RmvOnDestroy(this IRmv rmv, Node c) => c.Owner.GetNode<RmvOnDestroyTrigger>(c.GetPath()).Add(rmv);
        /// <summary>
        /// 标记为物体失活时注销
        /// </summary>
        public static void RmvOnDisable(this IRmv rmv, Node c) =>  c.Owner.GetNode<RmvOnDisableTrigger>(c.GetPath()).Add(rmv);
        /// <summary>
        /// 标记为场景卸载时注销
        /// </summary>
        public static void RmvOnSceneUnload(this IRmv rmv) => mWaitUnLoadRmvs.Push(rmv);
        /// <summary>
        /// 用于当前场景卸载时 注销所有事件和通知
        /// </summary>
        public static void OnSceneUnloadComplete()
        {
            while (mWaitUnLoadRmvs.Count > 0)
                mWaitUnLoadRmvs.Pop().Do();
        }
        // 用于存储所有当前场景卸载时 需要注销的事件和通知
        private readonly static Stack<IRmv> mWaitUnLoadRmvs = new Stack<IRmv>();
    }

