// PART OF THE MACHINE SIMULATION. DO NOT CHANGE.

package nachos.machine;

/**
 * A controller for all the elevators in an elevator bank. The controller accesses the elevator bank
 * through an instance of <tt>ElevatorControls</tt>.
 */
public interface ElevatorControllerInterface extends Runnable {
  /** The number of ticks doors should be held open before closing them. */
  int timeDoorsOpen = 500;
  /** Indicates an elevator intends to move down. */
  int dirDown = -1;
  /** Indicates an elevator intends not to move. */
  int dirNeither = 0;
  /** Indicates an elevator intends to move up. */
  int dirUp = 1;

  /**
   * Initialize this elevator controller. The controller will access the elevator bank through
   * <i>controls</i>. This constructor should return immediately after this controller is
   * initialized, but not until the interupt handler is set. The controller will start receiving
   * events after this method returns, but potentially before <tt>run()</tt> is called.
   *
   * @param controls the controller's interface to the elevator bank. The controller must not
   *     attempt to access the elevator bank in <i>any</i> other way.
   */
  void initialize(ElevatorControls controls);

  /**
   * Cause the controller to use the provided controls to receive and process requests from riders.
   * This method should not return, but instead should call <tt>controls.finish()</tt> when the
   * controller is finished.
   */
  void run();
}
