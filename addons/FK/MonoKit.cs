using System;
using Godot;
public partial class MonoKit : Node
{
    private static MonoKit mono;
    public static MonoKit GetIns() => mono;

    public static event Action OnUpdate;
    public static event Action OnFixedUpdate;

    public override void _EnterTree()
    {
        mono = this;
        base._EnterTree();
    }

    public override void _Process(double delta)
    {
        OnUpdate?.Invoke();
        base._Process(delta);
    }

    public override void _PhysicsProcess(double delta)
    {
        OnFixedUpdate?.Invoke();
        base._PhysicsProcess(delta);
    }
}