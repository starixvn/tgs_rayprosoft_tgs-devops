# lobby
export lobby=lobby-689
export image=lobby-t2
export lang=zh-CN
export domain=
export token=

envsubst < lobby-prod.yaml > sample.yaml
kubectl apply -f sample.yaml

# agent
export agent=agent-689
export image=pgtgs/agent:staging-2023-1114-0612
export lang=zh-CN
export site="https://stg-tgs689.rpgp.cc/"
export domain=stg-agent-tgs689.rpgp.cc
export token=eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiVEdTNjg5Iiwic3ViIjoiMzkyZWJlN2MtYmY3My00NDk0LWFmMzMtMDA0YzljNzFiOTA5IiwibmJmIjoxNzAwNzE3NzQxLCJleHAiOjE3MDA3MjEzNDEsImlhdCI6MTcwMDcxNzc0MSwiaXNzIjoidGdzIn0.G4fJeSBUG_N_0y89e91KFDkLn7TH5LOpxsKunkw9MWW3QpIoz0YDgVoom9TEIOg5w8yXYeqHZ3GzC4oor4cs1g4eObRW0z2r-Cwogh5Ls8PPeqM9Nspp64SMa4epEP5p-E1_nRdj6y5FMGID7uudvWHznmK-Mr_uYVRHmTGlEMMw_z0BrAKhGNFrIvMBr6MUPftB5BookiQ2RTe583eYLx46lkX8qzmPrSD0wmveiaF3U3HzNGrg0h7Ch1quHLvr0AWuNY4xreLF41bYQPMWY7GguBoiqUMKmA-MKeBXtUP2XDXWfwXX-Wo3d6z1fhdLfGOpedHefON6KrOv7eAsRA
envsubst < agent-staging.yaml > sample.yaml
kubectl apply -f sample.yaml