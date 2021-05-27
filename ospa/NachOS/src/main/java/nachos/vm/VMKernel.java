package nachos.vm;

import nachos.userprog.UserKernel;

/** A kernel that can support multiple demand-paging user processes. */
public class VMKernel extends UserKernel {
  private static final char dbgVM = 'v';
  // dummy variables to make javac smarter
  private static final VMProcess dummy1 = null;

  /** Allocate a new VM kernel. */
  public VMKernel() {
    super();
  }

  /** Initialize this kernel. */
  public void initialize(String[] args) {
    super.initialize(args);
  }

  /** Test this kernel. */
  public void selfTest() {
    super.selfTest();
  }

  /** Start running user programs. */
  public void run() {
    super.run();
  }

  /** Terminate this kernel. Never returns. */
  public void terminate() {
    super.terminate();
  }
}
