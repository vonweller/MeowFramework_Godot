### TaskScheduler 用户手册（支持 Unity 编辑器可视化配置）

本文档旨在为用户提供详细的 `TaskScheduler` 和 `TaskSchedulerUnity` 使用指南，重点介绍如何在 Unity 编辑器中可视化配置动画参数以及使用任务调度器的强大特性。文档不仅详细说明了每个类、方法的功能，还通过实例展示如何在 Unity 环境中高效使用任务调度器管理任务、控制动画。

---

## 核心概念

### 1. **任务调度器（TaskScheduler）**
`TaskScheduler` 是用于管理任务调度的核心类，支持任务的延迟执行、条件控制、重复执行、任务序列控制等。通过 `Step` 类，用户可以以链式调用的方式构建复杂的任务执行逻辑。

### 2. **`DelayTask`**
`DelayTask` 是用于处理延时任务的类，可以控制任务的启动、暂停、继续和停止，支持循环执行。它常用于控制任务在一定时间后执行。

### 3. **`Step`**
`Step` 是 `TaskScheduler` 中用于管理任务链的核心类。每个 `Step` 表示任务链中的一步操作，例如延迟、重复执行、条件判断或动画。通过链式调用，用户可以轻松构建复杂的任务序列。

### 4. **扩展模块（TaskSchedulerUnity）**
`TaskSchedulerUnity` 是为 Unity 环境设计的扩展模块，提供了可序列化的动画类，允许用户在 Unity 编辑器中直观地配置动画参数。此模块提供了丰富的动画类，如贝塞尔曲线、线性移动、弹性缩放、旋转等，并且所有动画类均可在编辑器中序列化和可视化。

---

## 任务调度器 API

### 1. **ITaskScheduler 接口**

`ITaskScheduler` 接口定义了 `TaskScheduler` 的所有核心方法，帮助用户控制任务的执行、序列管理等。

#### 方法详细介绍

1. **`AddDelayTask`**

   - **功能**：添加一个延时任务，任务将在指定时间后执行。
   - **参数**：
     - `duration`（float）：延时的持续时间（秒）。
     - `onFinished`（Action）：延时结束后要执行的任务。
     - `isLoop`（bool，可选）：是否循环执行任务。
     - `ignoreTimeScale`（bool，可选）：是否忽略时间缩放（适用于 Unity 的 `Time.timeScale` 设置）。
   - **返回**：返回一个 `DelayTask` 对象，表示该延时任务。
     

   **示例**：
   ```csharp
   var task = scheduler.AddDelayTask(5f, () => Debug.Log("延时结束"), isLoop: false);
   ```

   **使用场景**：在 UI 提示、游戏机制（如倒计时、延迟触发事件）等场景中广泛使用延时任务。

2. **`Sequence`**

   - **功能**：创建一个任务序列，序列允许多个任务按顺序执行，并支持添加延时、条件判断、动画等多种任务操作。
   - **返回**：返回一个 `Step` 对象，用于添加后续的任务操作。

   **示例**：
   ```csharp
   var step = scheduler.Sequence();
   step.Delay(2f).Event(() => Debug.Log("任务完成"));
   ```

   **使用场景**：用于构建任务链，确保多个任务按顺序执行，特别适用于复杂的任务调度场景。

3. **`RestartSequence`**

   - **功能**：重启某个任务序列，通常用于序列池的管理。
   - **参数**：`Step` 对象，表示需要重启的任务序列。

   **示例**：
   ```csharp
   scheduler.RestartSequence(step);
   ```

   **使用场景**：当某个任务序列需要重复使用时，通过此方法重启该任务序列。

4. **`StopSequence`**

   - **功能**：停止某个任务序列。
   - **参数**：`Step` 对象，表示需要停止的任务序列。

   **示例**：
   ```csharp
   scheduler.StopSequence(step);
   ```

   **使用场景**：用于任务中途强制停止，特别适用于需要手动干预任务链的场景。

5. **`PeriodicExecute`**

   - **功能**：在给定的持续时间内，每帧执行一次指定的任务。
   - **参数**：
     - `duration`（float）：任务执行的持续时间（秒）。
     - `onUpdate`（Action）：每帧更新时执行的任务。
     - `ignoreTimeScale`（bool，可选）：是否忽略时间缩放。
     

   **示例**：
   ```csharp
   scheduler.PeriodicExecute(5f, () => Debug.Log("每帧更新"), ignoreTimeScale: true);
   ```

   **使用场景**：适用于需要在一定时间内持续更新的任务，如时间倒数、计时器、界面动画等。

6. **`WaitExecute`**

   - **功能**：等待某个条件满足后执行任务。
   - **参数**：
     - `exit`（Func<bool>）：退出条件，返回 `true` 时执行任务。
     - `onFinished`（Action）：条件满足后执行的任务。
     - `ignoreTimeScale`（bool，可选）：是否忽略时间缩放。

   **示例**：
   ```csharp
   scheduler.WaitExecute(() => isReady, () => Debug.Log("条件满足"));
   ```

   **使用场景**：在需要等待外部条件（如用户输入、资源加载）的场景中广泛使用。

7. **`DelayExecute`**

   - **功能**：延迟执行某个任务。
   - **参数**：
     - `duration`（float）：延迟的时间（秒）。
     - `onFinished`（Action）：延迟结束后执行的任务。
     - `ignoreTimeScale`（bool，可选）：是否忽略时间缩放。
     

   **示例**：
   ```csharp
   scheduler.DelayExecute(3f, () => Debug.Log("3秒后执行"));
   ```

   **使用场景**：适用于需要短时间延迟触发任务的场景，例如提示显示、动画播放前的延迟。

8. **`UntilConditionExecute`**

   - **功能**：持续执行任务，直到某个条件满足为止。
   - **参数**：
     - `onExit`（Func<bool>）：退出条件，返回 `true` 时停止任务。
     - `onUpdate`（Action）：每帧更新时执行的任务。
     - `ignoreTimeScale`（bool 可选）：是否忽略时间缩放。
   
   
   **示例**：
   ```csharp
   scheduler.UntilConditionExecute(() => health <= 0, () => Debug.Log("更新中..."));
   ```
   
   **使用场景**：适用于需要在某一条件（如玩家状态、数值变化）成立时停止任务的场景。

---

### 2. **Step 类**

`Step` 类用于管理任务链中的每一步。每个 `Step` 可以添加延迟、事件、重复执行、动画等任务，并通过链式调用构建完整的任务序列。

#### 方法详细介绍

1. **`Delay`**
   - **功能**：延迟指定时间后执行任务。
   - **参数**：
     - `duration`（float）：延迟的时间。
     - `call`（Action，可选）：延迟结束后要执行的任务。

   **示例**：
   ```csharp
   step.Delay(2f, () => Debug.Log("2秒后执行"));
   ```

   **使用场景**：在任务执行过程中引入延迟，常用于任务链中的缓冲时间或过渡效果。

2. **`Event`**
   - **功能**：插入一个事件到任务链中。
   - **参数**：
     - `call`（Action）：要执行的任务逻辑。

   **示例**：
   ```csharp
   step.Event(() => Debug.Log("事件触发"));
   ```

   **使用场景**：用于在任务链中执行特定逻辑，如事件触发、状态更改等。

3. **`Repeat`**
   - **功能**：重复执行某个任务。
   - **参数**：
     - `repeatCount`（byte）：任务的重复次数。
     - `call`（Action 可选）：每次执行的任务。

   **示例**：
   ```csharp
   step.Repeat(3, () => Debug.Log("重复执行3次"));
   ```

   **使用场景**：适用于需要重复执行某任务的场景，如动画循环、状态刷新等。

4. **`Until`**
   - **功能**：在条件满足前重复执行任务。
   - **参数**：
     - `exit`（Func<bool>）：退出条件，返回 `true` 时停止执行。
     - `call`（Action）：每次执行的任务。

   **示例**

：
   ```csharp
   step.Until(() => isReady, () => Debug.Log("等待中"));
   ```

   **使用场景**：适用于需要等待某个条件成立之前持续执行任务的场景。

5. **`LoopGroup`**
   - **功能**：循环执行任务组，直到退出条件满足。
   - **参数**：
     - `onExit`（Func<bool>）：退出条件。
     - `call`（Action<Step> 可选）：包含循环任务的逻辑。

   **示例**：
   ```csharp
   step.LoopGroup(() => isGameOver, loopStep => loopStep.Event(() => Debug.Log("循环任务")));
   ```

   **使用场景**：常用于游戏循环逻辑或需要无限重复执行的任务场景。

6. **`BaseAnim`**
   - **功能**：插入一个自定义动画，通常用于弹性动画或基于物理的动画效果。
   - **参数**：
     - `act`：自定义动画实例。
   
   
   **示例**：
   ```csharp
   step.BaseAnim(elasticMoveInstance);
   ```
   
7. **`StateAnim`**
   - **功能**：插入带有状态控制的动画，支持提前跳出动画。
   - **参数**：
     - `act`：动画动作实例。
     - `leaveTime`：跳出的时间点。
     - `percentageMode`：是否以百分比模式计算时间点。

   **示例**：
   ```csharp
   step.StateAnim(stateAnimInstance, leaveTime: 2f);
   ```

8. **`PreCache`**
   - **功能**：预缓存初始值，用于提前存储动画或状态的初始设置。
   - **参数**：
     - `cache`：需要缓存的对象。

   **示例**：
   ```csharp
   step.PreCache(animationCache);
   ```

9. **`End`**
   - **功能**：标记任务序列的结束。

---

## `DelayTask` 类

`DelayTask` 是任务调度系统中处理延时任务的核心类。通过 `DelayTask`，用户可以控制任务的开始、暂停、继续、停止等操作，并支持循环执行。

### 方法详细介绍

1. **`Start`**
   - **功能**：启动延时任务。
   - **示例**：
     ```csharp
     delayTask.Start();
     ```

2. **`Pause`**
   - **功能**：暂停任务的执行。
   - **示例**：
     ```csharp
     delayTask.Pause();
     ```

3. **`Continue`**
   - **功能**：恢复任务的执行。
   - **示例**：
     ```csharp
     delayTask.Continue();
     ```

4. **`Stop`**
   - **功能**：停止任务的执行。
   - **示例**：
     ```csharp
     delayTask.Stop();
     ```

5. **`Complete`**
   - **功能**：立即完成任务。
   - **示例**：
     ```csharp
     delayTask.Complete();
     ```

6. **`IsEnd`**
   - **功能**：检查任务是否已完成。
   - **示例**：
     ```csharp
     bool isFinished = delayTask.IsEnd();
     ```

7. **`Update`**
   - **功能**：更新任务的状态，通常在每帧调用。
   - **示例**：
     ```csharp
     delayTask.Update(Time.deltaTime);
     ```

---

## TaskSchedulerUnity 动画类（支持 Unity 编辑器可视化）

`TaskSchedulerUnity` 提供了一系列动画类，这些类支持在 Unity 编辑器中进行可视化调节。用户可以通过编辑器界面直接修改动画参数，而无需在代码中硬编码，从而大大提升了开发效率和可操作性。

### 动画类详细介绍

#### **1. `Bezier2_Move_TV_V2`**
- **功能**：通过二次贝塞尔曲线控制 `Transform` 对象的移动。
- **可视化属性**：
  - `ctrl1`：控制点 1，用于调整曲线的弯曲程度。
  - `Cur`：当前对象的位置（序列化）。
- **使用场景**：适用于需要通过贝塞尔曲线进行非线性运动的物体动画，如UI移动路径。
- **Unity 编辑器配置**：
  在 Unity 编辑器中，用户可以调整控制点的位置，以直观地控制贝塞尔曲线的移动路径。
  
  **示例**：
  ```csharp
  [SerializeField]
  private Bezier2_Move_TV_V2 bezierMove;
  
  void Start() {
      scheduler.Sequence().BaseAnim(bezierMove);
  }
  ```

#### **2. `Bezier3_Move_TV_V2`**
- **功能**：通过三阶贝塞尔曲线控制 `Transform` 对象的移动，支持两个控制点。
- **可视化属性**：
  - `ctrl1`：控制点 1。
  - `ctrl2`：控制点 2。
  - `Cur`：当前对象的位置（序列化）。
- **使用场景**：适用于更加复杂的非线性路径移动场景，如UI动画或物体路径规划。
- **Unity 编辑器配置**：
  在 Unity 编辑器中，用户可以可视化地设置两个控制点，定义物体的移动路径。

  **示例**：
  ```csharp
  [SerializeField]
  private Bezier3_Move_TV_V2 bezier3Move;
  
  void Start() {
      scheduler.Sequence().BaseAnim(bezier3Move);
  }
  ```

#### **3. `Linear_Move_TV_V2`**
- **功能**：通过线性插值实现 `Transform` 对象的移动。
- **可视化属性**：
  - `Cur`：当前对象的位置（序列化）。
  - `local`：是否使用本地坐标系。
- **使用场景**：适用于线性移动的物体动画，如物体从一个点移动到另一个点的过程。
- **Unity 编辑器配置**：
  在 Unity 编辑器中，用户可以调整物体的起点和终点位置，实时预览物体的移动效果。

  **示例**：
  ```csharp
  [SerializeField]
  private Linear_Move_TV_V2 linearMove;
  
  void Start() {
      scheduler.Sequence().BaseAnim(linearMove);
  }
  ```

#### **4. `UI_Linear_Move_TT_V2`**
- **功能**：基于 `RectTransform` 的线性移动动画，常用于 UI 元素。
- **可视化属性**：
  - `Cur`：当前 UI 元素的位置（序列化）。
  - `target`：目标位置。
- **使用场景**：适用于UI元素在界面中的移动，如窗口滑入滑出效果。
- **Unity 编辑器配置**：
  用户可以在编辑器中直观调整 `RectTransform` 的初始位置和目标位置，实时预览动画效果。

  **示例**：
  ```csharp
  [SerializeField]
  private UI_Linear_Move_TT_V2 uiMove;
  
  void Start() {
      scheduler.Sequence().BaseAnim(uiMove);
  }
  ```

#### **5. `Elastic_Move_TV_V2`**
- **功能**：实现基于物理弹性的位移效果，模拟物体的弹性运动。
- **可视化属性**：
  - `Cur`：当前对象的位置。
  - `spring`：弹性系数，控制物体移动的弹性程度。
  - `fric`：摩擦系数，控制物体的减速。
- **使用场景**：适用于需要物理弹性运动的场景，如模拟物体的回弹、弹跳等效果。
- **Unity 编辑器配置**：
  用户可以在编辑器中调节弹性和摩擦系数，实时观察物体的弹性移动效果。

  **示例**：
  ```csharp
  [SerializeField]
  private Elastic_Move_TV_V2 elasticMove;
  
  void Start() {
      scheduler.Sequence().BaseAnim(elasticMove);
  }
  ```

#### **6. `Elastic_Scale_TV_V2`**
- **功能**：实现弹性缩放效果，适用于 `Transform` 的缩放动画。
- **可视化属性**：
  - `Cur`：当前对象的缩放。
  - `spring`：弹性系数，控制缩放的弹性效果。
  - `fric`：摩擦系数，控制缩放的阻尼效果。
- **使用场景**：适用于需要弹性缩放效果的场景，如UI元素的弹性放大或缩小。
- **Unity 编辑器配置**：
  用户可以调整弹性和摩擦系数，预览弹性缩放效果。

  **示例**：
  ```csharp
  [SerializeField]
  private Elastic_Scale_TV_V2 elasticScale;
  
  void Start() {
      scheduler.Sequence().BaseAnim(elasticScale);
  }
  ```

#### **7. `Linear_Scale_TV_V2`**
-

 **功能**：通过线性插值实现物体的缩放效果。
- **可视化属性**：
  - `Cur`：当前的缩放值。
  - `target`：目标缩放值。
- **使用场景**：适用于物体的线性缩放，如 UI 元素的放大、缩小等。
- **Unity 编辑器配置**：
  用户可以设置初始缩放和目标缩放值，并实时预览缩放动画。

  **示例**：
  ```csharp
  [SerializeField]
  private Linear_Scale_TV_V2 linearScale;
  
  void Start() {
      scheduler.Sequence().BaseAnim(linearScale);
  }
  ```

#### **8. `Elastic_Rot_TV_V2`**
- **功能**：实现弹性旋转效果，适用于 `Transform` 的旋转动画。
- **可视化属性**：
  - `Cur`：当前的旋转角度。
  - `spring`：弹性系数，控制旋转的弹性效果。
  - `fric`：摩擦系数，控制旋转的阻尼效果。
- **使用场景**：适用于需要弹性旋转的物体，如弹性转动的UI或3D物体。
- **Unity 编辑器配置**：
  用户可以调整弹性和摩擦系数，以获得合适的旋转动画效果。

  **示例**：
  ```csharp
  [SerializeField]
  private Elastic_Rot_TV_V2 elasticRot;
  
  void Start() {
      scheduler.Sequence().BaseAnim(elasticRot);
  }
  ```

#### **9. `Slerp_Move_TT_V3`**
- **功能**：在三维空间中实现球面插值（Slerp）移动，常用于平滑的 3D 物体移动。
- **可视化属性**：
  - `Cur`：当前对象的位置。
  - `target`：目标位置。
  - `speed`：移动速度。
- **使用场景**：适用于需要平滑移动的 3D 场景，如角色移动或物体跟踪。
- **Unity 编辑器配置**：
  用户可以调整起始位置、目标位置和速度，预览物体的平滑移动效果。

  **示例**：
  ```csharp
  [SerializeField]
  private Slerp_Move_TT_V3 slerpMove;
  
  void Start() {
      scheduler.Sequence().BaseAnim(slerpMove);
  }
  ```
