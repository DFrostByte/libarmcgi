char *ACGI_url_encode(const char *str, char *url);
unsigned int ACGI_url_encode_mem(const char *str);
char *ACGI_url_decode(char *url, char *write);
char *ACGI_is_uint(const char *str);
char *ACGI_rtrim(char *str, char *end);
char *ACGI_ltrim(char *str);
unsigned int ACGI_file_get_size(const char *path);
char *ACGI_file_to_str(const char *path, char *str);
extern const char *ACGI_tbl_url_valid_chars; //[256];
extern const char *ACGI_tbl_hex_chars; //"0123456789ABCDEF";
extern const char *ACGI_tbl_ascii_hex_val; //[256];

