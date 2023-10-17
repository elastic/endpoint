# Kernel Configuration with `make menuconfig`
You can find Elastic Defend's official list of supported Linux distributions and kernels [here](https://www.elastic.co/support/matrix).

Outside this list, there may be cases where a Linux kernel does not provide all the capabilities required for Defend to run. The following are experimental and unsupported steps to configure a Linux kernel on Gentoo to run Elastic Defend.

### `make menuconfig` instructions to enabled Elastic Defend:

NOTE: In order to compile the kernel with BTF `pahole` needs to be installed:
`emerge -av dev-util/pahole` 

1. First enable `CONFIG_DEBUG_INFO_DWARF4` to enable `CONFIG_DEBUG_INFO`
```
  | Symbol: DEBUG_INFO [=n]                                                                                                                                                                      │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at lib/Kconfig.debug:227                                                                                                                                                             │  
  │ Selected by [n]:                                                                                                                                                                             │  
  │   - DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT [=n] && <choice> && (!CC_IS_CLANG [=n] || AS_IS_LLVM [=n] || CLANG_VERSION [=0]<140000 || AS_IS_GNU [=y] && AS_VERSION [=24000]>=23502 && AS_HAS_NON_ │  
  │   - DEBUG_INFO_DWARF4 [=n] && <choice> && (!CC_IS_CLANG [=n] || AS_IS_LLVM [=n] || AS_IS_GNU [=y] && AS_VERSION [=24000]>=23502)                                                             │  
  │   - DEBUG_INFO_DWARF5 [=n] && <choice> && (!CC_IS_CLANG [=n] || AS_IS_LLVM [=n] || AS_IS_GNU [=y] && AS_VERSION [=24000]>=23502 && AS_HAS_NON_CONST_LEB128 [=y])   
```
```
  │ Symbol: DEBUG_INFO_DWARF4 [=n]                                                                                                                                                               │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at lib/Kconfig.debug:270                                                                                                                                                             │  
  │   Prompt: Generate DWARF Version 4 debuginfo                                                                                                                                                 │  
  │   Depends on: <choice> && (!CC_IS_CLANG [=n] || AS_IS_LLVM [=n] || AS_IS_GNU [=y] && AS_VERSION [=24000]>=23502)                                                                             │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Kernel hacking                                                                                                                                                                        │  
  │       -> Compile-time checks and compiler options                                                                                                                                            │  
  │         -> Debug information (<choice> [=y])                                                                                                                                                 │  
  │ (1)       -> Generate DWARF Version 4 debuginfo (DEBUG_INFO_DWARF4 [=n])                                                                                                                     │  
  │ Selects: DEBUG_INFO [=n]  
```
2. Second disable structure layout randomization (`CONFIG_RANDSTRUCT_NONE`) in order to allow for `CONFIG_DEBUG_INFO_BTF` to be enabled
```
  │ Symbol: DEBUG_INFO_BTF [=n]                                                                                                                                                                  │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at lib/Kconfig.debug:345                                                                                                                                                             │  
  │   Prompt: Generate BTF typeinfo                                                                                                                                                              │  
  │   Depends on: DEBUG_INFO [=y] && !DEBUG_INFO_SPLIT [=n] && !DEBUG_INFO_REDUCED [=n] && (!GCC_PLUGIN_RANDSTRUCT [=y] || COMPILE_TEST [=n]) && BPF_SYSCALL [=y] && (!DEBUG_INFO_DWARF5 [=n] || │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Kernel hacking                                                                                                                                                                        │  
  │ (1)   -> Compile-time checks and compiler options                                                                                                                                            │  
  │         -> Generate BTF typeinfo (DEBUG_INFO_BTF [=n])  
```
```
  │ Symbol: RANDSTRUCT_NONE [=n]                                                                                                                                                                 │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at security/Kconfig.hardening:312                                                                                                                                                    │  
  │   Prompt: Disable structure layout randomization                                                                                                                                             │  
  │   Depends on: <choice>                                                                                                                                                                       │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Security options                                                                                                                                                                      │  
  │       -> Kernel hardening options                                                                                                                                                            │  
  │         -> Randomize layout of sensitive kernel structures (<choice> [=y])                                                                                                                   │  
  │ (1)       -> Disable structure layout randomization (RANDSTRUCT_NONE [=n])     
```
NOTE:  Enabling `RANDSTRUCT_NONE` will provide the option in `make menuconfig` to enable `DEBUG_INFO_BTF`. Both `RANDSTRUCT_NONE` and `DEBUG_INFO_BTF` need to be enabled.

3. Export taskstats (`CONFIG_TASKSTATS`) to enable a eBPF hook point
```
  │ Symbol: TASKSTATS [=n]                                                                                                                                                                       │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at init/Kconfig:584                                                                                                                                                                  │  
  │   Prompt: Export task/process statistics through netlink                                                                                                                                     │  
  │   Depends on: NET [=y] && MULTIUSER [=y]                                                                                                                                                     │  
  │   Location:                                                                                                                                                                                  │  
  │     -> General setup                                                                                                                                                                         │  
  │       -> CPU/Task time and stats accounting                                                                                                                                                  │  
  │ (1)     -> Export task/process statistics through netlink (TASKSTATS [=n])    
```
4. Enable `CONFIG_SECURITY` to then enable fanotify permission events (`CONFIG_FANOTIFY_ACCESS_PERMISSIONS`)
```
  │ Symbol: FANOTIFY_ACCESS_PERMISSIONS [=n]                                                                                                                                                     │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at fs/notify/fanotify/Kconfig:15                                                                                                                                                     │  
  │   Prompt: fanotify permissions checking                                                                                                                                                      │  
  │   Depends on: FANOTIFY [=y] && SECURITY [=n]                                                                                                                                                 │  
  │   Location:                                                                                                                                                                                  │  
  │     -> File systems                                                                                                                                                                          │  
  │ (1)   -> Filesystem wide access notification (FANOTIFY [=y])                                                                                                                                 │  
  │         -> fanotify permissions checking (FANOTIFY_ACCESS_PERMISSIONS [=n])
```
```
  │ Symbol: SECURITY [=n]                                                                                                                                                                        │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at security/Kconfig:22                                                                                                                                                               │  
  │   Prompt: Enable different security models                                                                                                                                                   │  
  │   Depends on: SYSFS [=y] && MULTIUSER [=y]                                                                                                                                                   │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Security options                                                                                                                                                                      │  
  │ (1)   -> Enable different security models (SECURITY [=n])  
```
5. Enable network queueing disciplines for host isolation.
```
  │ Symbol: NET_CLS_ACT [=n]                                                                                                                                                                     
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at net/sched/Kconfig:742                                                                                                                                                             │  
  │   Prompt: Actions                                                                                                                                                                            │  
  │   Depends on: NET [=y] && NET_SCHED [=y]                                                                                                                                                     │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Networking support (NET [=y])                                                                                                                                                         │  
  │       -> Networking options                                                                                                                                                                  │  
  │         -> QoS and/or fair queueing (NET_SCHED [=y])                                                                                                                                         │  
  │ (2)       -> Actions (NET_CLS_ACT [=n])                                                                                                                                                      │  
  │ Selects: NET_CLS [=y]   
```
```
  │ Symbol: NET_CLS_BPF [=n]                                                                                                                                                                     │  
  │ Type  : tristate                                                                                                                                                                             │  
  │ Defined at net/sched/Kconfig:602                                                                                                                                                             │  
  │   Prompt: BPF-based classifier                                                                                                                                                               │  
  │   Depends on: NET [=y] && NET_SCHED [=y]                                                                                                                                                     │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Networking support (NET [=y])                                                                                                                                                         │  
  │       -> Networking options                                                                                                                                                                  │  
  │         -> QoS and/or fair queueing (NET_SCHED [=y])                                                                                                                                         │  
  │ (1)       -> BPF-based classifier (NET_CLS_BPF [=n])                                                                                                                                         │  
  │ Selects: NET_CLS [=y] 
```
```
  │ Symbol: NET_SCH_CBQ [=n]                                                                                                                                                                     │  
  │ Type  : tristate                                                                                                                                                                             │  
  │ Defined at net/sched/Kconfig:48                                                                                                                                                              │  
  │   Prompt: Class Based Queueing (CBQ)                                                                                                                                                         │  
  │   Depends on: NET [=y] && NET_SCHED [=y]                                                                                                                                                     │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Networking support (NET [=y])                                                                                                                                                         │  
  │       -> Networking options                                                                                                                                                                  │  
  │         -> QoS and/or fair queueing (NET_SCHED [=y])                                                                                                                                         │  
  │ (1)       -> Class Based Queueing (CBQ) (NET_SCH_CBQ [=n])  
```
```
  │ Symbol: NET_ACT_BPF [=y]                                                                                                                                                                     │  
  │ Type  : tristate                                                                                                                                                                             │  
  │ Defined at net/sched/Kconfig:890                                                                                                                                                             │  
  │   Prompt: BPF based action                                                                                                                                                                   │  
  │   Depends on: NET [=y] && NET_SCHED [=y] && NET_CLS_ACT [=y]                                                                                                                                 │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Networking support (NET [=y])                                                                                                                                                         │  
  │       -> Networking options                                                                                                                                                                  │  
  │         -> QoS and/or fair queueing (NET_SCHED [=y])                                                                                                                                         │  
  │           -> Actions (NET_CLS_ACT [=y])                                                                                                                                                      │  
  │ (1)         -> BPF based action (NET_ACT_BPF [=y])
```
```
  │ Symbol: NET_SCH_INGRESS [=y]                                                                                                                                                                 │  
  │ Type  : tristate                                                                                                                                                                             │  
  │ Defined at net/sched/Kconfig:382                                                                                                                                                             │  
  │   Prompt: Ingress/classifier-action Qdisc                                                                                                                                                    │  
  │   Depends on: NET [=y] && NET_SCHED [=y] && NET_CLS_ACT [=y]                                                                                                                                 │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Networking support (NET [=y])                                                                                                                                                         │  
  │       -> Networking options                                                                                                                                                                  │  
  │         -> QoS and/or fair queueing (NET_SCHED [=y])                                                                                                                                         │  
  │ (2)       -> Ingress/classifier-action Qdisc (NET_SCH_INGRESS [=y])                                                                                                                          │  
  │ Selects: NET_INGRESS [=y] && NET_EGRESS [=y]
```
6. Enable `CONFIG_SECURITY_NETWORK` for tracefs (kprobe) network event sources
```
  │ Symbol: SECURITY_NETWORK [=y]                                                                                                                                                                │  
  │ Type  : bool                                                                                                                                                                                 │  
  │ Defined at security/Kconfig:48                                                                                                                                                               │  
  │   Prompt: Socket and Networking Security Hooks                                                                                                                                               │  
  │   Depends on: SECURITY [=y]                                                                                                                                                                  │  
  │   Location:                                                                                                                                                                                  │  
  │     -> Security options                                                                                                                                                                      │  
  │ (1)   -> Socket and Networking Security Hooks (SECURITY_NETWORK [=y])                                                                                                                        │  
  │ Selected by [n]:                                                                                                                                                                             │  
  │   - SECURITY_SMACK [=n] && NET [=y] && INET [=y] && SECURITY [=y]                                                                                                                            │  
  │   - SECURITY_TOMOYO [=n] && SECURITY [=y] && NET [=y]                                                                                                                                        │  
  │   - SECURITY_APPARMOR [=n] && SECURITY [=y] && NET [=y] 
```

