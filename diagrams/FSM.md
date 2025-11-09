## S_IDLE

    R_CW <= 1;
    R_CH <= 1;
    R_CI <= 1;
    R_ACC <= 1;

    E_CW <= 0;
    E_CH <= 0;
    E_CI <= 0;
    E_ACC <= 0;

    done <= 1;
    sample_ready <= 0;
    read_mem <= 0

    Transição:
        Se enable = '1', vai para S_START.
        Senão, fica em S_IDLE.


## S_WINDOW_LOOP 
    
    read_mem <= 1
    E_CI <= 1;
    E_ACC <= 1;

    Transição:
        Vai para S_WINDOW_LOOP.


