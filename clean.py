import pandas as pd 
df = pd.read_csv("./titles_edit.csv")
df['releaseYear'] = df['releaseYear'].fillna(0).astype(int)
df['runtimeMinutes'] = df['runtimeMinutes'].fillna(0).astype(int)
print(df)
print("Longest title name length is:\n",df.primaryTitle.str.len().max())
print("Longest imdb_id length is:\n",df.imdb_id.str.len().max())
df.to_csv('./out.csv', index = False)  

# Still need to switch line end sequence to CRLF in vscode