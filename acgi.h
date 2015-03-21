char *ACGI_url_encode(const char *str, char *url);
unsigned int ACGI_url_encode_mem(const char *str);
char *ACGI_url_decode(char *url);
char *ACGI_is_uint(const char *str);
char *ACGI_rtrim(char *str);
extern const char *ACGI_tbl_url_valid_chars; //[256];
extern const char *ACGI_tbl_hex_chars; //"0123456789ABCDEF";
extern const char *ACGI_tbl_ascii_hex_val; //[256];

