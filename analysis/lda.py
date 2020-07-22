#!/usr/bin/env python
# coding: utf-8

# In[1]:


# Basic
import numpy as np
import pandas as pd
import math
import logging


# In[2]:


# NLP
import gensim
from gensim import corpora
from tqdm import tqdm
import nltk
from nltk.corpus import stopwords
from nltk.stem import PorterStemmer
ps = PorterStemmer()
from collections import defaultdict


# In[3]:


# Visualization
from wordcloud import WordCloud
import matplotlib
import matplotlib.pylab as plt
import pyLDAvis
import pyLDAvis.gensim
pyLDAvis.enable_notebook()


# In[5]:


# Import data 
df = pd.read_csv('../data/AmNat_allAbstracts.csv')
df = df.dropna(subset=['Abstract'])


# In[47]:


# Clean up texts
symbols = '.,?!-;*"…:—()%#$&_/@＼・'

def basic_preprocess(data):
    data = str(data)
    data = data.lower()

    def clean_special_chars(text, symbols):        
        for p in symbols:
            text = text.replace(p, ' ')
        return text

    data = clean_special_chars(data, symbols)
    return data

df['cleaned'] = df['Abstract'].apply(basic_preprocess)


# In[48]:


# remove stop words
#list
all_text = list(df['cleaned'])

# filter stopwords & stem words
stop_words = set(stopwords.words())
texts = [[ps.stem(word) for word in document.lower().split() if word not in stop_words] for document in all_text]

# reduce memory
# del df
del all_text


# In[65]:



# setting frequency
frequency = defaultdict(int)

# count the number of occurrences of the word
for text in texts:
    for token in text:
        frequency[token] += 1

# build only words above 30 into an array
texts = [[token for token in text if frequency[token] > 30] for text in texts]


# In[66]:


# Build dictionary

dictionary = corpora.Dictionary(texts)
dictionary.filter_extremes(no_above=0.8)

# vocab size
print('vocab size: ', len(dictionary))


# In[67]:


# Build corpus 
corpus = [dictionary.doc2bow(t) for t in texts]

# tfidf
tfidf = gensim.models.TfidfModel(corpus)

# make corpus_tfidf
corpus_tfidf = tfidf[corpus]


# In[59]:


# LDA model 
start = 5
limit = 25
step = 1

coherence_vals = []
perplexity_vals = []

for n_topic in tqdm(range(start, limit, step)):
    lda_model = gensim.models.ldamodel.LdaModel(corpus=corpus, id2word=dictionary, num_topics=n_topic, random_state=0)
    perplexity_vals.append(np.exp2(-lda_model.log_perplexity(corpus)))
    coherence_model_lda = gensim.models.CoherenceModel(model=lda_model, texts=texts, dictionary=dictionary, coherence='c_v')
    coherence_vals.append(coherence_model_lda.get_coherence())


# In[60]:


# evaluation
x = range(start, limit, step)

fig, ax1 = plt.subplots(figsize=(12,5))

# coherence
c1 = 'darkturquoise'
ax1.plot(x, coherence_vals, 'o-', color=c1)
ax1.set_xlabel('Num Topics')
ax1.set_ylabel('Coherence', color=c1); ax1.tick_params('y', colors=c1)

# perplexity
c2 = 'slategray'
ax2 = ax1.twinx()
ax2.plot(x, perplexity_vals, 'o-', color=c2)
ax2.set_ylabel('Perplexity', color=c2); ax2.tick_params('y', colors=c2)

# Vis
ax1.set_xticks(x)
fig.tight_layout()
plt.show()

plt.savefig('metrics.png') 


# In[68]:


# LDA Model
logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
lda_model = gensim.models.ldamodel.LdaModel(corpus=corpus, id2word=dictionary, num_topics=12, alpha='symmetric', random_state=0)


# In[72]:


# WordCloud


fig, axs = plt.subplots(ncols=2, nrows=math.ceil(lda_model.num_topics/2), figsize=(16,20))
axs = axs.flatten()

def color_func(word, font_size, position, orientation, random_state, font_path):
    return 'darkturquoise'

for i, t in enumerate(range(lda_model.num_topics)):

    x = dict(lda_model.show_topic(t, 30))
    im = WordCloud(
        background_color='black',
        color_func=color_func,
        max_words=4000,
        width=300, height=300,
        random_state=0
    ).generate_from_frequencies(x)
    axs[i].imshow(im.recolor(colormap= 'Paired_r' , random_state=244), alpha=0.98)
    axs[i].axis('off')
    axs[i].set_title('Topic '+str(t))

# vis
plt.tight_layout()
plt.show()

# save as png
plt.savefig('wordcloud.png') 


# In[70]:


# Vis PCoA
vis_pcoa = pyLDAvis.gensim.prepare(lda_model, corpus, dictionary, sort_topics=False)
vis_pcoa

# save as html
pyLDAvis.save_html(vis_pcoa, 'pyldavis_output_pcoa.html')


# In[ ]:




