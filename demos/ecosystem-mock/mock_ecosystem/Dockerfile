# Mock ecosystem container — runs simulated O.A.S.I.S. components
# from the E.C.H.O. simulation framework.

FROM python:3.12-slim

WORKDIR /opt/mock-ecosystem

# Install simulation framework
COPY simulation_framework/ /opt/simulation_framework/
RUN pip install --no-cache-dir -e "/opt/simulation_framework[all]"

# Copy mock ecosystem entrypoint
COPY mock_ecosystem/ /opt/mock-ecosystem/

CMD ["python", "entrypoint.py"]
