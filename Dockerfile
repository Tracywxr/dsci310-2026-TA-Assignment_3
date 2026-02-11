FROM rocker/rstudio:4.4.2

WORKDIR /home/rstudio/project

USER root
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')"

# 只先复制 lockfile（避免触发 renv autoloader）
COPY renv.lock renv.lock

# 关键：让 renv 不走项目本地库，直接用系统库；同时关掉可能导致 “Function not implemented” 的机制
ENV RENV_PATHS_LIBRARY=/usr/local/lib/R/site-library
ENV RENV_CONFIG_AUTOLOADER_ENABLED=FALSE
ENV RENV_CONFIG_SANDBOX_ENABLED=FALSE
ENV RENV_CONFIG_CACHE_ENABLED=FALSE
ENV RENV_CONFIG_R_VERSION_CHECK=FALSE

# 从 renv.lock 还原依赖（source of truth 仍然是 lockfile）
RUN R -e "renv::restore(lockfile='renv.lock', prompt=FALSE)"

# 现在再复制项目其他文件（包括 src/、renv/、.Rprofile 都无所谓）
COPY . .

USER rstudio
CMD ["Rscript", "src/use_cowsay.R"]


