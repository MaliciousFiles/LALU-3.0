	component hps_connection is
		port (
			address_export      : in    std_logic_vector(26 downto 0) := (others => 'X'); -- export
			clk_clk             : in    std_logic                     := 'X';             -- clk
			clock_export        : in    std_logic                     := 'X';             -- export
			delete_file_export  : in    std_logic                     := 'X';             -- export
			h2f_reset_reset_n   : out   std_logic;                                        -- reset_n
			memory_mem_a        : out   std_logic_vector(12 downto 0);                    -- mem_a
			memory_mem_ba       : out   std_logic_vector(2 downto 0);                     -- mem_ba
			memory_mem_ck       : out   std_logic;                                        -- mem_ck
			memory_mem_ck_n     : out   std_logic;                                        -- mem_ck_n
			memory_mem_cke      : out   std_logic;                                        -- mem_cke
			memory_mem_cs_n     : out   std_logic;                                        -- mem_cs_n
			memory_mem_ras_n    : out   std_logic;                                        -- mem_ras_n
			memory_mem_cas_n    : out   std_logic;                                        -- mem_cas_n
			memory_mem_we_n     : out   std_logic;                                        -- mem_we_n
			memory_mem_reset_n  : out   std_logic;                                        -- mem_reset_n
			memory_mem_dq       : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- mem_dq
			memory_mem_dqs      : inout std_logic                     := 'X';             -- mem_dqs
			memory_mem_dqs_n    : inout std_logic                     := 'X';             -- mem_dqs_n
			memory_mem_odt      : out   std_logic;                                        -- mem_odt
			memory_mem_dm       : out   std_logic;                                        -- mem_dm
			memory_oct_rzqin    : in    std_logic                     := 'X';             -- oct_rzqin
			name_stream_export  : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			read_data_export    : out   std_logic_vector(31 downto 0);                    -- export
			read_enable_export  : in    std_logic                     := 'X';             -- export
			reset_reset_n       : in    std_logic                     := 'X';             -- reset_n
			write_data_export   : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			write_enable_export : in    std_logic                     := 'X'              -- export
		);
	end component hps_connection;

	u0 : component hps_connection
		port map (
			address_export      => CONNECTED_TO_address_export,      --      address.export
			clk_clk             => CONNECTED_TO_clk_clk,             --          clk.clk
			clock_export        => CONNECTED_TO_clock_export,        --        clock.export
			delete_file_export  => CONNECTED_TO_delete_file_export,  --  delete_file.export
			h2f_reset_reset_n   => CONNECTED_TO_h2f_reset_reset_n,   --    h2f_reset.reset_n
			memory_mem_a        => CONNECTED_TO_memory_mem_a,        --       memory.mem_a
			memory_mem_ba       => CONNECTED_TO_memory_mem_ba,       --             .mem_ba
			memory_mem_ck       => CONNECTED_TO_memory_mem_ck,       --             .mem_ck
			memory_mem_ck_n     => CONNECTED_TO_memory_mem_ck_n,     --             .mem_ck_n
			memory_mem_cke      => CONNECTED_TO_memory_mem_cke,      --             .mem_cke
			memory_mem_cs_n     => CONNECTED_TO_memory_mem_cs_n,     --             .mem_cs_n
			memory_mem_ras_n    => CONNECTED_TO_memory_mem_ras_n,    --             .mem_ras_n
			memory_mem_cas_n    => CONNECTED_TO_memory_mem_cas_n,    --             .mem_cas_n
			memory_mem_we_n     => CONNECTED_TO_memory_mem_we_n,     --             .mem_we_n
			memory_mem_reset_n  => CONNECTED_TO_memory_mem_reset_n,  --             .mem_reset_n
			memory_mem_dq       => CONNECTED_TO_memory_mem_dq,       --             .mem_dq
			memory_mem_dqs      => CONNECTED_TO_memory_mem_dqs,      --             .mem_dqs
			memory_mem_dqs_n    => CONNECTED_TO_memory_mem_dqs_n,    --             .mem_dqs_n
			memory_mem_odt      => CONNECTED_TO_memory_mem_odt,      --             .mem_odt
			memory_mem_dm       => CONNECTED_TO_memory_mem_dm,       --             .mem_dm
			memory_oct_rzqin    => CONNECTED_TO_memory_oct_rzqin,    --             .oct_rzqin
			name_stream_export  => CONNECTED_TO_name_stream_export,  --  name_stream.export
			read_data_export    => CONNECTED_TO_read_data_export,    --    read_data.export
			read_enable_export  => CONNECTED_TO_read_enable_export,  --  read_enable.export
			reset_reset_n       => CONNECTED_TO_reset_reset_n,       --        reset.reset_n
			write_data_export   => CONNECTED_TO_write_data_export,   --   write_data.export
			write_enable_export => CONNECTED_TO_write_enable_export  -- write_enable.export
		);

